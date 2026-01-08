#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# SMOKE TEST V11.0.0 - QUICK SYSTEM VERIFICATION
# ════════════════════════════════════════════════════════════════════════════
# SOURCE TRACEABILITY:
#   - /mnt/project/SIGNAL-FLOW-SMOKE-TEST-PROTOCOL.md
#
# Purpose: Quick check that critical systems are working
# Duration: < 30 seconds
# Use: Run before pm-validator for fast feedback
# ════════════════════════════════════════════════════════════════════════════

VERSION="11.0.0"

echo "════════════════════════════════════════════════════════════════════════════"
echo "  🚀 SMOKE TEST V11.0.0 - QUICK SYSTEM CHECK"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

PASS=0
FAIL=0

smoke() {
    local name=$1
    local cmd=$2
    
    if eval "$cmd" > /dev/null 2>&1; then
        echo "✅ $name"
        ((PASS++)) || true
    else
        echo "❌ $name"
        ((FAIL++)) || true
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# CRITICAL CHECKS (All must pass)
# ─────────────────────────────────────────────────────────────────────────────

echo "=== CRITICAL CHECKS ==="
smoke "Docker running" "docker info"
smoke "Docker Compose available" "docker compose version"
smoke "Network available" "curl -s --max-time 5 https://api.anthropic.com"
smoke "jq installed" "which jq"
smoke "curl installed" "which curl"
smoke "bc installed" "which bc"

echo ""
echo "=== FILE CHECKS ==="

# Load .env if exists
[ -f .env ] && source .env 2>/dev/null

# Check for test structure
if [ -d "LOCKED" ] && [ -d "CONFIGURABLE" ]; then
    smoke "MAF V11 structure (LOCKED/CONFIGURABLE)" "true"
elif [ -f "docker-compose.yml" ]; then
    smoke "Legacy structure (docker-compose.yml)" "true"
else
    smoke "Package structure" "false"
fi

smoke ".env file exists" "[ -f .env ]"
smoke "ANTHROPIC_API_KEY set" "[ -n \"$ANTHROPIC_API_KEY\" ]"

echo ""
echo "=== OPTIONAL CHECKS ==="
smoke "SLACK_WEBHOOK_URL set" "[ -n \"$SLACK_WEBHOOK_URL\" ]" || true
smoke "GITHUB_TOKEN set" "[ -n \"$GITHUB_TOKEN\" ]" || true

# ─────────────────────────────────────────────────────────────────────────────
# RESULTS
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════════════════════"

if [ $FAIL -eq 0 ]; then
    echo "  ✅ SMOKE TEST PASSED ($PASS checks)"
    echo "  → Run pm-validator-v6.0.sh for full validation"
    echo "════════════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo "  ❌ SMOKE TEST FAILED ($FAIL failures)"
    echo "  → Fix critical issues before proceeding"
    echo "════════════════════════════════════════════════════════════════════════════"
    exit 1
fi
