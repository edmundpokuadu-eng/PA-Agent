#!/usr/bin/env bash
# transmit_session.sh — Transmit consented session logs to PA-Agent-Data
# Part of the PA-Agent research study (Edmund Poku Adu, Arkansas State University)
#
# Usage: bash scripts/transmit_session.sh [path/to/workflow_state.json]
#
# Requirements:
#   - PA_AGENT_DATA_TOKEN environment variable set to a GitHub PAT with Issues write
#     access to edmundpokuadu-eng/PA-Agent-Data
#   - curl installed
#   - jq installed (optional but recommended; falls back to grep)

set -euo pipefail

REPO="edmundpokuadu-eng/PA-Agent-Data"
API_URL="https://api.github.com/repos/${REPO}/issues"
CHUNK_LIMIT=60000  # Stay under GitHub's 65536 char limit with margin

# --- Argument parsing ---
WORKFLOW_STATE="${1:-./workflow_state.json}"

if [[ ! -f "$WORKFLOW_STATE" ]]; then
    echo "ERROR: workflow_state.json not found at: $WORKFLOW_STATE"
    echo "Usage: bash scripts/transmit_session.sh [path/to/workflow_state.json]"
    exit 1
fi

# --- Check consent ---
if command -v jq &>/dev/null; then
    CONSENT=$(jq -r '.consent_granted // false' "$WORKFLOW_STATE")
    WITHDRAWN=$(jq -r '.consent_withdrawn // false' "$WORKFLOW_STATE")
    SESSION_ID=$(jq -r '.session_id // "unknown"' "$WORKFLOW_STATE")
else
    CONSENT=$(grep -o '"consent_granted"[[:space:]]*:[[:space:]]*true' "$WORKFLOW_STATE" && echo "true" || echo "false")
    WITHDRAWN=$(grep -o '"consent_withdrawn"[[:space:]]*:[[:space:]]*true' "$WORKFLOW_STATE" && echo "true" || echo "false")
    SESSION_ID=$(grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$WORKFLOW_STATE" | head -1 | sed 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
fi

if [[ "$CONSENT" != "true" ]]; then
    echo "Consent not granted. No data will be transmitted."
    exit 0
fi

if [[ "$WITHDRAWN" == "true" ]]; then
    echo "Consent was withdrawn. No data will be transmitted."
    exit 0
fi

# --- Check authentication ---
if [[ -z "${PA_AGENT_DATA_TOKEN:-}" ]]; then
    echo "ERROR: PA_AGENT_DATA_TOKEN environment variable not set."
    echo "Set it to a GitHub PAT with Issues write access to ${REPO}."
    echo "  export PA_AGENT_DATA_TOKEN='ghp_your_token_here'"
    exit 1
fi

AUTH_HEADER="Authorization: token ${PA_AGENT_DATA_TOKEN}"

# --- Locate session log ---
# Claude Code stores session logs in ~/.claude/projects/<slug>/<uuid>.jsonl
WORKING_DIR=$(dirname "$(realpath "$WORKFLOW_STATE")")
PROJECT_SLUG=$(echo "$WORKING_DIR" | sed 's|/|-|g; s|^-||')
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

SESSION_LOG=""
if [[ -d "${CLAUDE_PROJECTS_DIR}/${PROJECT_SLUG}" ]]; then
    # Find the most recent .jsonl file
    SESSION_LOG=$(ls -t "${CLAUDE_PROJECTS_DIR}/${PROJECT_SLUG}"/*.jsonl 2>/dev/null | head -1)
fi

# --- Build payload ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
WORKFLOW_CONTENT=$(cat "$WORKFLOW_STATE")

if [[ -n "$SESSION_LOG" ]]; then
    LOG_CONTENT=$(cat "$SESSION_LOG")
else
    LOG_CONTENT="[Session log file not found. Only workflow state is available.]"
fi

FULL_BODY="## Session: ${SESSION_ID}

**Submission Timestamp:** ${TIMESTAMP}
**Workflow State File:** ${WORKFLOW_STATE}

### Workflow State

\`\`\`json
${WORKFLOW_CONTENT}
\`\`\`

### Session Log

\`\`\`
${LOG_CONTENT}
\`\`\`"

BODY_LENGTH=${#FULL_BODY}

# --- Helper: create a GitHub issue ---
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    # Escape the body for JSON
    local escaped_body
    escaped_body=$(printf '%s' "$body" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '%s' "$body" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | awk '{printf "%s\\n", $0}' | sed '$ s/\\n$//')

    # If python3 was used, escaped_body already has quotes; if sed fallback, wrap in quotes
    if command -v python3 &>/dev/null; then
        local json_payload="{\"title\":\"${title}\",\"body\":${escaped_body},\"labels\":[${labels}]}"
    else
        local json_payload="{\"title\":\"${title}\",\"body\":\"${escaped_body}\",\"labels\":[${labels}]}"
    fi

    local response
    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
        -H "$AUTH_HEADER" \
        -H "Accept: application/vnd.github+json" \
        -H "Content-Type: application/json" \
        -d "$json_payload")

    local http_code
    http_code=$(echo "$response" | tail -1)
    local response_body
    response_body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "201" ]]; then
        local issue_number
        if command -v jq &>/dev/null; then
            issue_number=$(echo "$response_body" | jq -r '.number')
        else
            issue_number=$(echo "$response_body" | grep -o '"number":[0-9]*' | head -1 | sed 's/"number"://')
        fi
        echo "$issue_number"
    else
        echo "ERROR: Failed to create issue (HTTP $http_code)" >&2
        echo "$response_body" >&2
        echo ""
    fi
}

# --- Transmit ---
echo "Transmitting session ${SESSION_ID}..."
echo "Payload size: ${BODY_LENGTH} characters"

if [[ $BODY_LENGTH -le $CHUNK_LIMIT ]]; then
    # Single-part submission
    echo "Single-part submission..."
    ISSUE_NUM=$(create_issue \
        "Session: ${SESSION_ID}" \
        "$FULL_BODY" \
        "\"session-log\",\"single-part\"")

    if [[ -n "$ISSUE_NUM" ]]; then
        echo "SUCCESS: Session log submitted as issue #${ISSUE_NUM}"
        echo "URL: https://github.com/${REPO}/issues/${ISSUE_NUM}"
    else
        echo "FAILED: Could not create issue. Check your token and permissions."
        exit 1
    fi
else
    # Multi-part submission
    NUM_CHUNKS=$(( (BODY_LENGTH + CHUNK_LIMIT - 1) / CHUNK_LIMIT ))
    echo "Multi-part submission: ${NUM_CHUNKS} chunks needed..."

    # Create manifest issue first
    MANIFEST_BODY="## Session: ${SESSION_ID} (Multi-Part Manifest)

**Submission Timestamp:** ${TIMESTAMP}
**Total Size:** ${BODY_LENGTH} characters
**Chunks:** ${NUM_CHUNKS}
**Chunk Issues:** (listed below as they are created)

### Workflow State

\`\`\`json
${WORKFLOW_CONTENT}
\`\`\`"

    MANIFEST_NUM=$(create_issue \
        "Session: ${SESSION_ID} [Manifest]" \
        "$MANIFEST_BODY" \
        "\"session-log\",\"manifest\"")

    if [[ -z "$MANIFEST_NUM" ]]; then
        echo "FAILED: Could not create manifest issue."
        exit 1
    fi
    echo "Manifest issue: #${MANIFEST_NUM}"

    # Split and submit chunks
    CHUNK_ISSUES=()
    OFFSET=0
    CHUNK_NUM=1

    while [[ $OFFSET -lt ${#LOG_CONTENT} ]]; do
        CHUNK_TEXT="${LOG_CONTENT:$OFFSET:$CHUNK_LIMIT}"
        CHUNK_BODY="## Session: ${SESSION_ID} --- Chunk ${CHUNK_NUM}/${NUM_CHUNKS}

**Manifest Issue:** #${MANIFEST_NUM}

\`\`\`
${CHUNK_TEXT}
\`\`\`"

        CHUNK_ISSUE_NUM=$(create_issue \
            "Session: ${SESSION_ID} [Chunk ${CHUNK_NUM}/${NUM_CHUNKS}]" \
            "$CHUNK_BODY" \
            "\"session-log\",\"chunk\"")

        if [[ -n "$CHUNK_ISSUE_NUM" ]]; then
            echo "  Chunk ${CHUNK_NUM}/${NUM_CHUNKS}: issue #${CHUNK_ISSUE_NUM}"
            CHUNK_ISSUES+=("$CHUNK_ISSUE_NUM")
        else
            echo "  WARNING: Chunk ${CHUNK_NUM} failed to upload."
        fi

        OFFSET=$(( OFFSET + CHUNK_LIMIT ))
        CHUNK_NUM=$(( CHUNK_NUM + 1 ))
    done

    echo ""
    echo "SUCCESS: Session log submitted in ${#CHUNK_ISSUES[@]} chunks."
    echo "Manifest: https://github.com/${REPO}/issues/${MANIFEST_NUM}"
    for cn in "${CHUNK_ISSUES[@]}"; do
        echo "  Chunk: https://github.com/${REPO}/issues/${cn}"
    done
fi

echo ""
echo "Thank you for contributing to the PA-Agent research study."
