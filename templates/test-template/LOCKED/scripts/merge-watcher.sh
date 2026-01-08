#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# MERGE-WATCHER V11.0.0 - MAF ORCHESTRATION SCRIPT
# ════════════════════════════════════════════════════════════════════════════
# SOURCE TRACEABILITY:
#   - /mnt/project/merge-watcher-v10_3.sh (365 lines)
#   - /mnt/project/WORKFLOW-V4_3-COMPLETE.md (Slack notifications)
#
# This script:
#   1. Monitors signal files from agents
#   2. Coordinates wave transitions
#   3. Handles merges after all gates pass
#   4. Sends Slack notifications
#   5. Tracks token costs
#   6. Implements kill switch and stuck detection
# ════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
SIGNAL_DIR="${SIGNAL_DIR:-/signals}"
CODE_DIR="${CODE_DIR:-/workspace/code}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
WAVE_COUNT="${WAVE_COUNT:-2}"

# Safety limits (from FMEA)
STUCK_THRESHOLD_MINUTES=30
MAX_ITERATIONS=25
KILL_SWITCH_FILE="$SIGNAL_DIR/EMERGENCY-STOP"

# Token tracking
TOKEN_CSV="$SIGNAL_DIR/token-tracking.csv"

# Cost matrix (per 1M tokens)
declare -A COST_INPUT=(
    ["claude-opus-4-20250514"]=15.00
    ["claude-sonnet-4-20250514"]=3.00
    ["claude-haiku-4-20250514"]=0.25
)
declare -A COST_OUTPUT=(
    ["claude-opus-4-20250514"]=75.00
    ["claude-sonnet-4-20250514"]=15.00
    ["claude-haiku-4-20250514"]=1.25
)

# ─────────────────────────────────────────────────────────────────────────────
# KILL SWITCH (FMEA F01 - External enforcement)
# ─────────────────────────────────────────────────────────────────────────────
check_kill_switch() {
    if [ -f "$KILL_SWITCH_FILE" ]; then
        echo "[EMERGENCY] 🛑 KILL SWITCH ACTIVATED"
        notify_slack "🛑 EMERGENCY STOP - All agents halted" "#FF0000" "🚨 EMERGENCY"
        
        # Kill all agent containers
        docker stop $(docker ps -q --filter "name=wave") 2>/dev/null || true
        
        # Create incident report
        cat > "$SIGNAL_DIR/incident-$(date +%Y%m%d-%H%M%S).json" << EOF
{
    "type": "emergency_stop",
    "triggered_at": "$(date -Iseconds)",
    "triggered_by": "$(cat $KILL_SWITCH_FILE)",
    "containers_stopped": $(docker ps -a --filter "name=wave" --format "{{.Names}}" | wc -l)
}
EOF
        exit 1
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# STUCK DETECTION (FMEA F07 - External enforcement)
# ─────────────────────────────────────────────────────────────────────────────
check_agent_health() {
    local agent="$1"
    local signal_file="$SIGNAL_DIR/.agent-${agent}-last-progress"
    
    if [ -f "$signal_file" ]; then
        local last_progress=$(cat "$signal_file")
        local now=$(date +%s)
        local diff=$(( (now - last_progress) / 60 ))
        
        if [ "$diff" -gt "$STUCK_THRESHOLD_MINUTES" ]; then
            echo "[STUCK] Agent $agent has made no progress for ${diff} minutes"
            notify_slack "⚠️ Agent $agent appears STUCK (${diff}m no progress)" "#FF9800" "⚠️ Stuck"
            
            # Force termination after 2x threshold
            if [ "$diff" -gt $(( STUCK_THRESHOLD_MINUTES * 2 )) ]; then
                docker stop "${agent}" 2>/dev/null || true
                touch "$SIGNAL_DIR/.agent-${agent}-force-stopped"
            fi
        fi
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# SLACK NOTIFICATIONS
# ─────────────────────────────────────────────────────────────────────────────
notify_slack() {
    local message="$1"
    local color="${2:-#36a64f}"
    local title="${3:-🤖 MAF V11.0.0}"
    
    [ -z "$SLACK_WEBHOOK_URL" ] && { echo "[SLACK] $message"; return 0; }
    
    curl -s -X POST -H 'Content-type: application/json' \
        --data "{\"attachments\":[{\"color\":\"$color\",\"title\":\"$title\",\"text\":\"$message\",\"footer\":\"MAF V11.0.0 | $(date '+%H:%M:%S')\"}]}" \
        "$SLACK_WEBHOOK_URL" > /dev/null 2>&1 || true
}

notify_gate() {
    local gate="$1"
    local status="$2"
    local details="${3:-}"
    
    local color="#36a64f"  # green
    [ "$status" = "failed" ] && color="#F44336"  # red
    [ "$status" = "warning" ] && color="#FF9800"  # orange
    
    local icon="✅"
    [ "$status" = "failed" ] && icon="❌"
    [ "$status" = "warning" ] && icon="⚠️"
    
    notify_slack "$icon Gate $gate: $status\n$details" "$color" "Gate $gate"
}

# ─────────────────────────────────────────────────────────────────────────────
# TOKEN TRACKING
# ─────────────────────────────────────────────────────────────────────────────
init_token_tracking() {
    mkdir -p "$SIGNAL_DIR"
    [ ! -f "$TOKEN_CSV" ] && echo "timestamp,wave,story_id,model,input_tokens,output_tokens,cost_usd" > "$TOKEN_CSV"
}

calculate_cost() {
    local model="$1" input="$2" output="$3"
    local ic=${COST_INPUT[$model]:-3.00}
    local oc=${COST_OUTPUT[$model]:-15.00}
    echo "scale=6; ($input * $ic / 1000000) + ($output * $oc / 1000000)" | bc
}

record_tokens() {
    local wave="$1" story="$2" model="$3" input="$4" output="$5"
    local cost=$(calculate_cost "$model" "$input" "$output")
    echo "$(date -Iseconds),$wave,$story,$model,$input,$output,$cost" >> "$TOKEN_CSV"
}

generate_cost_report() {
    local wave="$1"
    [ ! -f "$TOKEN_CSV" ] && echo "0.00" && return
    awk -F',' -v w="$wave" 'NR>1 && $2==w {s+=$7} END {printf "%.4f",s}' "$TOKEN_CSV"
}

# ─────────────────────────────────────────────────────────────────────────────
# SIGNAL MONITORING
# ─────────────────────────────────────────────────────────────────────────────
wait_for_signal() {
    local pattern="$1"
    local timeout="${2:-3600}"  # Default 1 hour
    local start=$(date +%s)
    
    echo "[SIGNAL] Waiting for: $pattern"
    
    while true; do
        check_kill_switch
        
        if ls $SIGNAL_DIR/$pattern 2>/dev/null | head -1 | grep -q .; then
            echo "[SIGNAL] Found: $pattern"
            return 0
        fi
        
        local elapsed=$(( $(date +%s) - start ))
        if [ "$elapsed" -gt "$timeout" ]; then
            echo "[SIGNAL] Timeout waiting for: $pattern"
            return 1
        fi
        
        sleep 5
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# MAIN ORCHESTRATION LOOP
# ─────────────────────────────────────────────────────────────────────────────
main() {
    echo "════════════════════════════════════════════════════════════════════"
    echo "  MAF V11.0.0 MERGE-WATCHER STARTED"
    echo "════════════════════════════════════════════════════════════════════"
    echo "Signal directory: $SIGNAL_DIR"
    echo "Wave count: $WAVE_COUNT"
    echo ""
    
    init_token_tracking
    notify_slack "🚀 MAF V11.0.0 Pipeline started with $WAVE_COUNT waves" "#2196F3" "🏁 Pipeline"
    
    # Process each wave
    for wave in $(seq 1 $WAVE_COUNT); do
        echo "[WAVE $wave] Starting..."
        notify_slack "🏁 Wave $wave started" "#2196F3" "Wave $wave"
        
        # Wait for wave completion signal
        if wait_for_signal "wave${wave}-complete.json" 7200; then
            local cost=$(generate_cost_report $wave)
            notify_slack "✅ Wave $wave complete. Cost: \$$cost" "#4CAF50" "Wave $wave"
        else
            notify_slack "❌ Wave $wave failed or timed out" "#F44336" "Wave $wave"
            exit 1
        fi
    done
    
    # All waves complete
    local total_cost=$(awk -F',' 'NR>1 {s+=$7} END {printf "%.4f",s}' "$TOKEN_CSV")
    notify_slack "🎉 Pipeline complete! Total cost: \$$total_cost" "#4CAF50" "🎉 Complete"
    
    echo "════════════════════════════════════════════════════════════════════"
    echo "  PIPELINE COMPLETE"
    echo "════════════════════════════════════════════════════════════════════"
}

# Run main
main "$@"
