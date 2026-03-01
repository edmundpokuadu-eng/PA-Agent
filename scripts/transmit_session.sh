#!/usr/bin/env bash
# transmit_session.sh — Transmit consented session logs to the PA-Agent study
# Part of the PA-Agent research study (Edmund Poku Adu, Arkansas State University)
#
# Usage: bash scripts/transmit_session.sh [path/to/workflow_state.json]
#
# Requirements:
#   - curl (pre-installed on macOS and most Linux systems)
#   - jq (optional; falls back to grep)
#
# No GitHub account, CLI tools, or special tokens are needed.
# Data is transmitted via a public HTTPS endpoint to a secure
# Google Sheet accessible only to the principal investigator.

set -euo pipefail

# --- Configuration ---
# The PA-Agent study data endpoint. This is a Google Apps Script web app
# that writes submitted session data to a private Google Sheet.
ENDPOINT_URL="https://script.google.com/macros/s/AKfycbyRrhH6P9rbDgkxV0LjVGZRDmHhet2ukPcpNLDYOPiQhEjc6e7Ga5164yHC7iIT88q-QQ/exec"

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
    AGENT=$(jq -r '.agent // "unknown"' "$WORKFLOW_STATE")
    FIELD=$(jq -r '.field // "unknown"' "$WORKFLOW_STATE")
    STAGE=$(jq -r '.stage // "unknown"' "$WORKFLOW_STATE")
else
    CONSENT=$(grep -o '"consent_granted"[[:space:]]*:[[:space:]]*true' "$WORKFLOW_STATE" && echo "true" || echo "false")
    WITHDRAWN=$(grep -o '"consent_withdrawn"[[:space:]]*:[[:space:]]*true' "$WORKFLOW_STATE" && echo "true" || echo "false")
    SESSION_ID=$(grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$WORKFLOW_STATE" | head -1 | sed 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    AGENT="unknown"
    FIELD="unknown"
    STAGE="unknown"
fi

if [[ "$CONSENT" != "true" ]]; then
    echo "Consent not granted. No data will be transmitted."
    exit 0
fi

if [[ "$WITHDRAWN" == "true" ]]; then
    echo "Consent was withdrawn. No data will be transmitted."
    exit 0
fi

# --- Check endpoint is configured ---
if [[ "$ENDPOINT_URL" == "__PASTE_YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL_HERE__" ]]; then
    echo "ERROR: Data endpoint URL not configured."
    echo "The study PI must deploy the Google Apps Script and update ENDPOINT_URL in this script."
    exit 1
fi

# --- Locate session log ---
# Claude Code stores session logs in ~/.claude/projects/<slug>/<uuid>.jsonl
WORKING_DIR=$(dirname "$(realpath "$WORKFLOW_STATE")")
PROJECT_SLUG=$(echo "$WORKING_DIR" | sed 's|/|-|g; s|^-||')
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"

SESSION_LOG=""
if [[ -d "${CLAUDE_PROJECTS_DIR}/${PROJECT_SLUG}" ]]; then
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

PAYLOAD_SIZE=${#LOG_CONTENT}

echo "Transmitting session ${SESSION_ID}..."
echo "Session log size: ${PAYLOAD_SIZE} characters"

# --- Chunk and transmit ---
# Google Apps Script has a ~50MB request limit, but we chunk at 5MB
# to keep individual requests fast and reliable.
CHUNK_LIMIT=5000000  # 5MB per chunk
TOTAL_CHUNKS=$(( (PAYLOAD_SIZE + CHUNK_LIMIT - 1) / CHUNK_LIMIT ))
if [[ $TOTAL_CHUNKS -lt 1 ]]; then
    TOTAL_CHUNKS=1
fi

send_chunk() {
    local chunk_num="$1"
    local total="$2"
    local chunk_data="$3"

    # Use python3 to build valid JSON (handles all escaping)
    local json_payload
    json_payload=$(python3 -c "
import json, sys
payload = {
    'session_id': sys.argv[1],
    'agent': sys.argv[2],
    'field': sys.argv[3],
    'stage': sys.argv[4],
    'timestamp': sys.argv[5],
    'chunk': int(sys.argv[6]),
    'total_chunks': int(sys.argv[7]),
    'workflow_state': sys.argv[8],
    'session_log': sys.argv[9]
}
print(json.dumps(payload))
" "$SESSION_ID" "$AGENT" "$FIELD" "$STAGE" "$TIMESTAMP" "$chunk_num" "$total" "$WORKFLOW_CONTENT" "$chunk_data" 2>/dev/null)

    if [[ -z "$json_payload" ]]; then
        echo "ERROR: Failed to build JSON payload (python3 required for JSON encoding)." >&2
        return 1
    fi

    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "$ENDPOINT_URL" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        --max-time 120)

    if [[ "$http_code" == "200" || "$http_code" == "302" ]]; then
        return 0
    else
        echo "WARNING: Server returned HTTP ${http_code} for chunk ${chunk_num}." >&2
        return 1
    fi
}

if [[ $TOTAL_CHUNKS -eq 1 ]]; then
    # Single submission
    echo "Submitting in one request..."
    if send_chunk 1 1 "$LOG_CONTENT"; then
        echo "SUCCESS: Session log submitted."
    else
        echo "FAILED: Could not submit session log. Check your internet connection."
        exit 1
    fi
else
    # Multi-chunk submission
    echo "Large session log — submitting in ${TOTAL_CHUNKS} chunks..."
    OFFSET=0
    CHUNK_NUM=1
    FAILURES=0

    while [[ $OFFSET -lt $PAYLOAD_SIZE ]]; do
        CHUNK_DATA="${LOG_CONTENT:$OFFSET:$CHUNK_LIMIT}"

        if send_chunk "$CHUNK_NUM" "$TOTAL_CHUNKS" "$CHUNK_DATA"; then
            echo "  Chunk ${CHUNK_NUM}/${TOTAL_CHUNKS}: submitted"
        else
            echo "  Chunk ${CHUNK_NUM}/${TOTAL_CHUNKS}: FAILED"
            FAILURES=$((FAILURES + 1))
        fi

        OFFSET=$(( OFFSET + CHUNK_LIMIT ))
        CHUNK_NUM=$(( CHUNK_NUM + 1 ))
    done

    if [[ $FAILURES -eq 0 ]]; then
        echo "SUCCESS: Session log submitted in ${TOTAL_CHUNKS} chunks."
    else
        echo "WARNING: ${FAILURES} chunk(s) failed. Please retry or contact eadu@astate.edu."
        exit 1
    fi
fi

echo ""
echo "Thank you for contributing to the PA-Agent research study."
echo "Questions? Contact Edmund Poku Adu at eadu@astate.edu"
