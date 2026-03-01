#!/usr/bin/env bash
# transmit_session.sh — Transmit consented session logs to PA-Agent-Data
# Part of the PA-Agent research study (Edmund Poku Adu, Arkansas State University)
#
# Usage: bash scripts/transmit_session.sh [path/to/workflow_state.json]
#
# Requirements:
#   - gh CLI installed and authenticated (https://cli.github.com)
#   - jq installed (optional but recommended; falls back to grep)
#
# The data collection repo (PA-Agent-Data) is public. Any GitHub user
# authenticated with `gh auth login` can submit session logs. No special
# tokens or permissions are needed.

set -euo pipefail

REPO="edmundpokuadu-eng/PA-Agent-Data"
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

# --- Check gh CLI ---
if ! command -v gh &>/dev/null; then
    echo "ERROR: GitHub CLI (gh) is not installed."
    echo "Install it from https://cli.github.com and run 'gh auth login' to authenticate."
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "ERROR: GitHub CLI is not authenticated."
    echo "Run 'gh auth login' to authenticate with your GitHub account."
    exit 1
fi

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

# --- Transmit ---
echo "Transmitting session ${SESSION_ID}..."
echo "Payload size: ${BODY_LENGTH} characters"

if [[ $BODY_LENGTH -le $CHUNK_LIMIT ]]; then
    # Single-part submission
    echo "Single-part submission..."
    ISSUE_URL=$(gh issue create \
        --repo "$REPO" \
        --title "Session: ${SESSION_ID}" \
        --body "$FULL_BODY" \
        --label "session-log,single-part" 2>&1)

    if [[ $? -eq 0 ]]; then
        echo "SUCCESS: Session log submitted."
        echo "URL: ${ISSUE_URL}"
    else
        echo "FAILED: Could not create issue."
        echo "$ISSUE_URL"
        exit 1
    fi
else
    # Multi-part submission
    NUM_CHUNKS=$(( (${#LOG_CONTENT} + CHUNK_LIMIT - 1) / CHUNK_LIMIT ))
    echo "Multi-part submission: ${NUM_CHUNKS} chunks needed..."

    # Create manifest issue first
    MANIFEST_BODY="## Session: ${SESSION_ID} (Multi-Part Manifest)

**Submission Timestamp:** ${TIMESTAMP}
**Total Size:** ${BODY_LENGTH} characters
**Chunks:** ${NUM_CHUNKS}

### Workflow State

\`\`\`json
${WORKFLOW_CONTENT}
\`\`\`"

    MANIFEST_URL=$(gh issue create \
        --repo "$REPO" \
        --title "Session: ${SESSION_ID} [Manifest]" \
        --body "$MANIFEST_BODY" \
        --label "session-log,manifest" 2>&1)

    if [[ $? -ne 0 ]]; then
        echo "FAILED: Could not create manifest issue."
        echo "$MANIFEST_URL"
        exit 1
    fi
    echo "Manifest: ${MANIFEST_URL}"

    # Extract manifest issue number from URL
    MANIFEST_NUM=$(echo "$MANIFEST_URL" | grep -o '[0-9]*$')

    # Split and submit chunks
    OFFSET=0
    CHUNK_NUM=1
    CHUNK_URLS=()

    while [[ $OFFSET -lt ${#LOG_CONTENT} ]]; do
        CHUNK_TEXT="${LOG_CONTENT:$OFFSET:$CHUNK_LIMIT}"
        CHUNK_BODY="## Session: ${SESSION_ID} --- Chunk ${CHUNK_NUM}/${NUM_CHUNKS}

**Manifest Issue:** #${MANIFEST_NUM}

\`\`\`
${CHUNK_TEXT}
\`\`\`"

        CHUNK_URL=$(gh issue create \
            --repo "$REPO" \
            --title "Session: ${SESSION_ID} [Chunk ${CHUNK_NUM}/${NUM_CHUNKS}]" \
            --body "$CHUNK_BODY" \
            --label "session-log,chunk" 2>&1)

        if [[ $? -eq 0 ]]; then
            echo "  Chunk ${CHUNK_NUM}/${NUM_CHUNKS}: ${CHUNK_URL}"
            CHUNK_URLS+=("$CHUNK_URL")
        else
            echo "  WARNING: Chunk ${CHUNK_NUM} failed to upload."
        fi

        OFFSET=$(( OFFSET + CHUNK_LIMIT ))
        CHUNK_NUM=$(( CHUNK_NUM + 1 ))
    done

    echo ""
    echo "SUCCESS: Session log submitted in ${#CHUNK_URLS[@]} chunks."
    echo "Manifest: ${MANIFEST_URL}"
fi

echo ""
echo "Thank you for contributing to the PA-Agent research study."
