#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# SAFETY DETECTOR V11.0.0 - REAL-TIME FORBIDDEN OPERATION DETECTION
# ════════════════════════════════════════════════════════════════════════════
# SOURCE TRACEABILITY:
#   - /mnt/project/COMPLETE-SAFETY-REFERENCE.md (108 forbidden operations)
#   - /mnt/project/autonomous-agent-safety-guardrails-benchmark.md
#
# Purpose: Monitor logs for forbidden operations and alert immediately
# Usage: ./safety-detector.sh [LOG_FILE or -]
# ════════════════════════════════════════════════════════════════════════════

VERSION="11.0.0"
LOG_FILE="${1:--}"  # Default to stdin

echo "════════════════════════════════════════════════════════════════════════════"
echo "  🛡️ SAFETY DETECTOR V11.0.0 - MONITORING FOR FORBIDDEN OPERATIONS"
echo "════════════════════════════════════════════════════════════════════════════"
echo "Monitoring: $LOG_FILE"
echo "Press Ctrl+C to stop"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# FORBIDDEN PATTERNS (from SAFETY-PROTOCOL.md)
# ─────────────────────────────────────────────────────────────────────────────

# Database destruction
DB_PATTERNS=(
    'DROP\s+DATABASE'
    'DROP\s+TABLE'
    'DROP\s+SCHEMA'
    'TRUNCATE\s+TABLE'
    'DELETE\s+FROM\s+\w+\s*$'
    'DELETE\s+FROM\s+\w+\s+WHERE\s+1=1'
    'UPDATE\s+\w+\s+SET\s+.*\s*$'
)

# File system destruction
FS_PATTERNS=(
    'rm\s+-rf\s+/'
    'rm\s+-rf\s+~'
    'rm\s+-rf\s+\.'
    'rm\s+-rf\s+\*'
    'rm\s+-rf\s+\.git'
    'rm\s+-rf\s+\.env'
    'find\s+\.\s+-delete'
)

# Git destruction
GIT_PATTERNS=(
    'git\s+push\s+--force'
    'git\s+push\s+-f'
    'git\s+reset\s+--hard'
    'git\s+branch\s+-D\s+(main|master)'
    'git\s+rebase\s+-i'
)

# Privilege escalation
PRIV_PATTERNS=(
    'sudo\s+'
    'chmod\s+777'
    'chown\s+root'
)

# Secrets exposure
SECRET_PATTERNS=(
    'cat\s+\.env'
    'echo\s+\$API_KEY'
    'echo\s+\$SECRET'
    'echo\s+\$ANTHROPIC'
    'printenv\s*\|\s*grep'
)

# Remote code execution
RCE_PATTERNS=(
    'curl\s+.*\|\s*bash'
    'wget\s+.*\|\s*sh'
    'curl\s+-o-.*\|\s*bash'
)

# Build combined pattern
ALL_PATTERNS=("${DB_PATTERNS[@]}" "${FS_PATTERNS[@]}" "${GIT_PATTERNS[@]}" "${PRIV_PATTERNS[@]}" "${SECRET_PATTERNS[@]}" "${RCE_PATTERNS[@]}")

# ─────────────────────────────────────────────────────────────────────────────
# MONITORING FUNCTION
# ─────────────────────────────────────────────────────────────────────────────
VIOLATIONS=0

check_line() {
    local line="$1"
    
    for pattern in "${ALL_PATTERNS[@]}"; do
        if echo "$line" | grep -qiE "$pattern"; then
            ((VIOLATIONS++)) || true
            
            echo ""
            echo "════════════════════════════════════════════════════════════════════════════"
            echo "🚨 FORBIDDEN OPERATION DETECTED (#$VIOLATIONS)"
            echo "════════════════════════════════════════════════════════════════════════════"
            echo "Pattern: $pattern"
            echo "Line: $line"
            echo "Time: $(date)"
            echo ""
            
            # Optional: Send Slack alert
            if [ -n "$SLACK_WEBHOOK_URL" ]; then
                curl -s -X POST "$SLACK_WEBHOOK_URL" \
                    -H "Content-Type: application/json" \
                    -d "{\"text\":\"🚨 FORBIDDEN OPERATION DETECTED\\n\\\`\`\`$line\\\`\`\`\"}" \
                    > /dev/null 2>&1
            fi
            
            return 1
        fi
    done
    
    return 0
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN MONITORING LOOP
# ─────────────────────────────────────────────────────────────────────────────

# Monitor from file or stdin
if [ "$LOG_FILE" = "-" ]; then
    # Read from stdin (pipe mode)
    while IFS= read -r line; do
        check_line "$line"
    done
else
    # Read from file (tail mode)
    if [ -f "$LOG_FILE" ]; then
        tail -f "$LOG_FILE" | while IFS= read -r line; do
            check_line "$line"
        done
    else
        echo "❌ File not found: $LOG_FILE"
        exit 1
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# USAGE EXAMPLES
# ─────────────────────────────────────────────────────────────────────────────
# 
# Monitor docker logs:
#   docker logs -f container_name | ./safety-detector.sh
#
# Monitor file:
#   ./safety-detector.sh /var/log/agent.log
#
# Monitor multiple containers:
#   docker compose logs -f | ./safety-detector.sh
#
# ════════════════════════════════════════════════════════════════════════════
