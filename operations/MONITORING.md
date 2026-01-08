# MAF V11.0.0 MONITORING GUIDE
## Dashboards, Alerts, and Observability

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - /mnt/project/PRODUCTION-MONITORING-STACK.md
  - /mnt/project/ALERTING-RULES-MATRIX.md
  - /mnt/project/WORKFLOW-V4_3-COMPLETE.md (Slack notifications)
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0

---

## Monitoring Stack Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MAF V11.0.0 MONITORING STACK                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │   AGENTS    │───►│   SIGNALS   │───►│   ALERTS    │                     │
│  │  (Docker)   │    │   (JSON)    │    │  (Slack)    │                     │
│  └─────────────┘    └─────────────┘    └─────────────┘                     │
│         │                 │                   │                             │
│         ▼                 ▼                   ▼                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │   DOZZLE    │    │   TOKEN     │    │   COST      │                     │
│  │   (Logs)    │    │  TRACKING   │    │  REPORTS    │                     │
│  └─────────────┘    └─────────────┘    └─────────────┘                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Slack Notifications

### Setup

1. Go to https://api.slack.com/apps
2. Create New App → From scratch
3. Name: "MAF V11.0.0 Pipeline"
4. Enable Incoming Webhooks
5. Add webhook to your channel
6. Copy webhook URL

### Configure

```bash
# In .env
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T.../B.../xxx
```

### Notification Events

| Event | Emoji | Color | Example |
|-------|-------|-------|---------|
| Pipeline Start | 🚀 | Blue | "Pipeline started: 2 waves, 4 stories" |
| Gate Complete | ✅ | Green | "Gate 4 QA: APPROVED" |
| Gate Failed | ❌ | Red | "Gate 4 QA: REJECTED - API mismatch" |
| Agent Stuck | ⚠️ | Orange | "fe-auth stuck for 35 min" |
| Cost Report | 💰 | Blue | "Wave 1 Cost: $0.54" |
| Pipeline Complete | 🎉 | Green | "Complete! Total: $2.30" |
| Emergency Stop | 🛑 | Red | "EMERGENCY STOP activated" |

### Custom Notifications

```bash
# Add to merge-watcher.sh
notify_slack() {
    local message="$1"
    local color="${2:-good}"
    local title="${3:-MAF V11.0.0}"
    
    curl -s -X POST "$SLACK_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"attachments\": [{
                \"color\": \"$color\",
                \"title\": \"$title\",
                \"text\": \"$message\",
                \"footer\": \"MAF V11.0.0 | $(date '+%H:%M:%S')\"
            }]
        }"
}

# Usage
notify_slack "Wave 1 complete" "good" "✅ Success"
notify_slack "Agent stuck" "#FF9800" "⚠️ Warning"
notify_slack "Pipeline failed" "danger" "❌ Error"
```

---

## 2. Dozzle (Web-Based Logs)

### Setup

Add to docker-compose.yml:

```yaml
services:
  dozzle:
    image: amir20/dozzle:latest
    container_name: dozzle
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```

### Access

Open http://localhost:8080 in browser

### Features

- Real-time log streaming
- Filter by container
- Search across logs
- Multi-container view

---

## 3. Token Tracking

### CSV Format

```csv
timestamp,wave,story_id,model,input_tokens,output_tokens,cost_usd
2026-01-08T10:00:00Z,1,AUTH-FE-001,claude-sonnet-4,50000,10000,0.30
2026-01-08T10:05:00Z,1,AUTH-BE-001,claude-sonnet-4,45000,8000,0.27
```

### Cost Calculation

```bash
# Cost per 1M tokens
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

# Calculate
calculate_cost() {
    local model="$1" input="$2" output="$3"
    local ic=${COST_INPUT[$model]}
    local oc=${COST_OUTPUT[$model]}
    echo "scale=4; ($input * $ic / 1000000) + ($output * $oc / 1000000)" | bc
}
```

### Generate Report

```bash
# Daily cost summary
awk -F',' 'NR>1 {sum+=$7} END {printf "Daily total: $%.2f\n", sum}' token-tracking.csv

# By wave
awk -F',' 'NR>1 {cost[$2]+=$7} END {for(w in cost) printf "Wave %s: $%.2f\n", w, cost[w]}' token-tracking.csv

# By model
awk -F',' 'NR>1 {cost[$4]+=$7} END {for(m in cost) printf "%s: $%.2f\n", m, cost[m]}' token-tracking.csv
```

---

## 4. Safety Monitoring

### Kill Switch Check

The merge-watcher continuously checks for emergency stop:

```bash
# Check every iteration
KILL_SWITCH_FILE="$SIGNAL_DIR/EMERGENCY-STOP"

if [ -f "$KILL_SWITCH_FILE" ]; then
    echo "🛑 EMERGENCY STOP"
    docker stop $(docker ps -q --filter "name=wave")
    notify_slack "🛑 EMERGENCY STOP activated" "danger"
    exit 1
fi
```

### Activate Kill Switch

```bash
# Create kill switch file
echo "Manual stop by operator at $(date)" > signals/EMERGENCY-STOP
```

### Stuck Detection

```bash
# Track agent progress
STUCK_THRESHOLD=30  # minutes

check_stuck() {
    local agent="$1"
    local last_file="signals/.agent-${agent}-last-progress"
    
    if [ -f "$last_file" ]; then
        local last=$(cat "$last_file")
        local now=$(date +%s)
        local diff=$(( (now - last) / 60 ))
        
        if [ "$diff" -gt "$STUCK_THRESHOLD" ]; then
            notify_slack "⚠️ $agent stuck for ${diff}m" "#FF9800"
            
            # Force stop after 2x threshold
            if [ "$diff" -gt $(( STUCK_THRESHOLD * 2 )) ]; then
                docker stop "$agent"
            fi
        fi
    fi
}
```

---

## 5. Dashboard (Optional)

For a custom dashboard, you can use the Supabase database + a simple web interface:

### Data to Display

| Metric | Source | Update |
|--------|--------|--------|
| Active agents | Docker API | Real-time |
| Current gate | Signal files | Real-time |
| Token usage | CSV/Database | Per story |
| Total cost | Calculated | Per wave |
| Error count | Logs | Real-time |

### Simple HTML Dashboard

```html
<!-- dashboard.html -->
<!DOCTYPE html>
<html>
<head>
    <title>MAF V11.0.0 Dashboard</title>
    <script>
        async function refresh() {
            const resp = await fetch('/api/status');
            const data = await resp.json();
            document.getElementById('agents').innerText = data.activeAgents;
            document.getElementById('cost').innerText = '$' + data.totalCost;
            document.getElementById('gate').innerText = 'Gate ' + data.currentGate;
        }
        setInterval(refresh, 5000);
    </script>
</head>
<body>
    <h1>MAF V11.0.0 Pipeline</h1>
    <div>Active Agents: <span id="agents">-</span></div>
    <div>Current Gate: <span id="gate">-</span></div>
    <div>Total Cost: <span id="cost">-</span></div>
</body>
</html>
```

---

## 6. Alert Rules

### Critical Alerts (Immediate Action)

| Condition | Action | Notification |
|-----------|--------|--------------|
| Agent error 3x | Stop agent | Slack + SMS |
| Budget > $100/day | Stop wave | Slack + SMS |
| Kill switch activated | Stop all | Slack + SMS |
| Security violation | Stop all | Slack + SMS |

### Warning Alerts (Monitor)

| Condition | Action | Notification |
|-----------|--------|--------------|
| Agent stuck 30m | Watch | Slack |
| Token budget 80% | Watch | Slack |
| Build failure | Retry | Slack |
| QA rejection | Dev fix | Slack |

### Info Alerts (Log)

| Condition | Action | Notification |
|-----------|--------|--------------|
| Gate complete | Continue | Slack |
| Wave complete | Next wave | Slack |
| Cost report | Log | Slack |

---

## Quick Reference

### Essential Commands

```bash
# View all logs
docker compose logs -f

# View specific agent
docker logs -f wave1-fe-dev

# Check active containers
docker ps

# Check signals
ls -la signals/

# View cost tracking
cat signals/token-tracking.csv

# Activate kill switch
echo "Manual stop" > signals/EMERGENCY-STOP

# Check if stuck
find signals -name "*.json" -mmin +30
```

### Monitoring URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Dozzle | http://localhost:8080 | Log viewer |
| Anthropic Console | https://console.anthropic.com | API usage |
| Slack | Your workspace | Notifications |

---

**Document Status:** OPERATIONS (update as needed)
