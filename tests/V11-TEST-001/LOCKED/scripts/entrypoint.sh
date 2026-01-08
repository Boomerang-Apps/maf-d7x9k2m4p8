#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# ENTRYPOINT V11.0.0 - AGENT STARTUP SCRIPT
# ════════════════════════════════════════════════════════════════════════════
# SOURCE TRACEABILITY:
#   - /mnt/project/AUTONOMOUS-AGENT-SETUP-GUIDE.md
#   - /mnt/project/CLAUDE-CODE-PROTOCOL-V1_3.md
#
# This script:
#   1. Sets up the agent environment
#   2. Records start time for stuck detection
#   3. Executes Claude with proper flags
#   4. Tracks token usage
#   5. Creates completion signals
# ════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
AGENT_ID="${AGENT_ID:-unknown}"
DOMAIN="${DOMAIN:-unknown}"
ROLE="${ROLE:-dev}"
STORY_ID="${STORY_ID:-UNKNOWN-000}"
SIGNAL_DIR="${SIGNAL_DIR:-/workspace/.claude/signals}"

# ─────────────────────────────────────────────────────────────────────────────
# STARTUP
# ─────────────────────────────────────────────────────────────────────────────
echo "════════════════════════════════════════════════════════════════════"
echo "  MAF V11.0.0 AGENT: $AGENT_ID"
echo "════════════════════════════════════════════════════════════════════"
echo "Domain: $DOMAIN"
echo "Role: $ROLE"
echo "Story: $STORY_ID"
echo "Started: $(date -Iseconds)"
echo ""

# Create signal directory
mkdir -p "$SIGNAL_DIR"

# Record start time for stuck detection
echo "$(date +%s)" > "$SIGNAL_DIR/.agent-${AGENT_ID}-last-progress"

# Create start signal
cat > "$SIGNAL_DIR/agent-${AGENT_ID}-started.json" << EOF
{
    "agent_id": "$AGENT_ID",
    "domain": "$DOMAIN",
    "role": "$ROLE",
    "story_id": "$STORY_ID",
    "started_at": "$(date -Iseconds)"
}
EOF

# ─────────────────────────────────────────────────────────────────────────────
# PROMPT CONSTRUCTION
# ─────────────────────────────────────────────────────────────────────────────
# Get prompt from environment or file
if [ -n "${AGENT_PROMPT:-}" ]; then
    PROMPT="$AGENT_PROMPT"
elif [ -f "/workspace/stories/${STORY_ID}.md" ]; then
    PROMPT=$(cat "/workspace/stories/${STORY_ID}.md")
else
    echo "[ERROR] No prompt provided and no story file found"
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# EXECUTE CLAUDE
# ─────────────────────────────────────────────────────────────────────────────
echo "[CLAUDE] Starting Claude Code CLI..."
echo "[CLAUDE] Using --dangerously-skip-permissions flag for autonomous execution"

# Execute Claude with proper flags
# --dangerously-skip-permissions: Required for autonomous execution
# --output-format stream-json: For token tracking
# -p: Prompt mode (non-interactive)

claude -p "$PROMPT" \
    --dangerously-skip-permissions \
    --output-format stream-json \
    2>&1 | tee "$SIGNAL_DIR/agent-${AGENT_ID}-output.log"

EXIT_CODE=$?

# ─────────────────────────────────────────────────────────────────────────────
# COMPLETION
# ─────────────────────────────────────────────────────────────────────────────
# Record completion
echo "$(date +%s)" > "$SIGNAL_DIR/.agent-${AGENT_ID}-last-progress"

# Create completion signal
cat > "$SIGNAL_DIR/agent-${AGENT_ID}-complete.json" << EOF
{
    "agent_id": "$AGENT_ID",
    "domain": "$DOMAIN",
    "role": "$ROLE",
    "story_id": "$STORY_ID",
    "started_at": "$(cat $SIGNAL_DIR/agent-${AGENT_ID}-started.json | jq -r '.started_at')",
    "completed_at": "$(date -Iseconds)",
    "exit_code": $EXIT_CODE,
    "status": "$([ $EXIT_CODE -eq 0 ] && echo 'success' || echo 'failed')"
}
EOF

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo "  AGENT COMPLETE: $AGENT_ID"
echo "  Exit Code: $EXIT_CODE"
echo "════════════════════════════════════════════════════════════════════"

exit $EXIT_CODE
