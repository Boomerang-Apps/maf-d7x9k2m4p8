#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# PM VALIDATOR V6.0 - MAF V11.0.0 PRE-FLIGHT VALIDATION
# ════════════════════════════════════════════════════════════════════════════
# SOURCE TRACEABILITY:
#   - /mnt/project/pm-validator-v5_5.sh (736 lines)
#   - Simplified for V11.0.0 LOCKED/CONFIGURABLE pattern
#
# Purpose: Validate test package BEFORE execution
# Checks: Environment, credentials, structure, safety, stories
# ════════════════════════════════════════════════════════════════════════════

VERSION="6.0.0"
PACKAGE_DIR="${1:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0
TOTAL=0

# Change to package directory
cd "$PACKAGE_DIR" || { echo -e "${RED}❌ Cannot access $PACKAGE_DIR${NC}"; exit 1; }

echo "════════════════════════════════════════════════════════════════════════════"
echo "  🔬 PM VALIDATOR V6.0 - MAF V11.0.0 PRE-FLIGHT CHECK"
echo "════════════════════════════════════════════════════════════════════════════"
echo "Package: $(pwd)"
echo "Date: $(date)"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# HELPER FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────
check() {
    local name=$1
    local result=$2
    local required=${3:-true}
    
    ((TOTAL++)) || true
    
    if [ "$result" = "true" ]; then
        echo -e "${GREEN}✅ $name${NC}"
        ((PASS++)) || true
    elif [ "$required" = "true" ]; then
        echo -e "${RED}❌ $name${NC}"
        ((FAIL++)) || true
    else
        echo -e "${YELLOW}⚠️  $name (optional)${NC}"
        ((WARN++)) || true
    fi
}

section() {
    echo ""
    echo -e "${BLUE}═══ $1 ═══${NC}"
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION A: EXECUTION ENVIRONMENT
# ─────────────────────────────────────────────────────────────────────────────
section "SECTION A: EXECUTION ENVIRONMENT"

check "A1: Docker daemon running" "$(docker info > /dev/null 2>&1 && echo true || echo false)"
check "A2: Docker Compose available" "$(docker compose version > /dev/null 2>&1 && echo true || echo false)"
check "A3: .env file exists" "$([ -f .env ] && echo true || echo false)"

# Load .env if exists
[ -f .env ] && source .env 2>/dev/null

check "A4: ANTHROPIC_API_KEY set" "$([ -n \"$ANTHROPIC_API_KEY\" ] && [ \"$ANTHROPIC_API_KEY\" != \"sk-ant-xxxxx\" ] && echo true || echo false)"

# A5: Live API key validation
if [ -n "$ANTHROPIC_API_KEY" ] && [ "$ANTHROPIC_API_KEY" != "sk-ant-xxxxx" ]; then
    API_TEST=$(curl -s --max-time 10 -X POST https://api.anthropic.com/v1/messages \
        -H "Content-Type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d '{"model":"claude-sonnet-4-20250514","max_tokens":1,"messages":[{"role":"user","content":"hi"}]}' 2>&1)
    
    if echo "$API_TEST" | grep -q '"type":"message"'; then
        check "A5: API key valid (live test)" "true"
    elif echo "$API_TEST" | grep -q 'rate_limit'; then
        check "A5: API key valid (rate limited but working)" "true"
    else
        check "A5: API key valid (live test)" "false"
    fi
else
    check "A5: API key valid (live test)" "false"
fi

check "A6: Network connectivity" "$(curl -s --max-time 5 https://api.anthropic.com > /dev/null 2>&1 && echo true || echo false)" false

# ─────────────────────────────────────────────────────────────────────────────
# SECTION B: MAF V11 STRUCTURE (LOCKED/CONFIGURABLE)
# ─────────────────────────────────────────────────────────────────────────────
section "SECTION B: MAF V11 STRUCTURE"

# Check for LOCKED files
check "B1: LOCKED/CLAUDE.md exists" "$([ -f LOCKED/CLAUDE.md ] && echo true || echo false)"
check "B2: LOCKED/docker-compose.yml exists" "$([ -f LOCKED/docker-compose.yml ] && echo true || echo false)"
check "B3: LOCKED/Dockerfile.agent exists" "$([ -f LOCKED/Dockerfile.agent ] && echo true || echo false)"
check "B4: LOCKED/scripts/merge-watcher.sh exists" "$([ -f LOCKED/scripts/merge-watcher.sh ] && echo true || echo false)"

# Check for CONFIGURABLE files
check "B5: CONFIGURABLE/.env.template or .env exists" "$([ -f CONFIGURABLE/.env.template ] || [ -f .env ] && echo true || echo false)"
check "B6: CONFIGURABLE/config.json exists" "$([ -f CONFIGURABLE/config.json ] && echo true || echo false)"
check "B7: CONFIGURABLE/stories/ directory exists" "$([ -d CONFIGURABLE/stories ] && echo true || echo false)"

# Count stories
STORY_COUNT=$(find CONFIGURABLE/stories -name "*.json" 2>/dev/null | wc -l)
check "B8: At least one story exists ($STORY_COUNT found)" "$([ $STORY_COUNT -gt 0 ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION C: DOCKER CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
section "SECTION C: DOCKER CONFIGURATION"

COMPOSE_FILE=""
[ -f LOCKED/docker-compose.yml ] && COMPOSE_FILE="LOCKED/docker-compose.yml"
[ -f docker-compose.yml ] && COMPOSE_FILE="docker-compose.yml"

if [ -n "$COMPOSE_FILE" ]; then
    check "C1: docker-compose.yml valid YAML" "$(docker compose -f $COMPOSE_FILE config > /dev/null 2>&1 && echo true || echo false)"
    check "C2: Uses depends_on: service_completed_successfully" "$(grep -q 'service_completed_successfully' $COMPOSE_FILE && echo true || echo false)"
    check "C3: Uses non-root user" "$(grep -q 'claudeuser\|USER\s' LOCKED/Dockerfile.agent 2>/dev/null && echo true || echo false)"
    check "C4: Uses --dangerously-skip-permissions" "$(grep -q '\-\-dangerously-skip-permissions' $COMPOSE_FILE && echo true || echo false)"
else
    check "C1: docker-compose.yml exists" "false"
fi

DOCKERFILE=""
[ -f LOCKED/Dockerfile.agent ] && DOCKERFILE="LOCKED/Dockerfile.agent"
[ -f Dockerfile.agent ] && DOCKERFILE="Dockerfile.agent"

if [ -n "$DOCKERFILE" ]; then
    check "C5: No ENTRYPOINT in Dockerfile" "$(! grep -q '^ENTRYPOINT' $DOCKERFILE && echo true || echo false)"
    check "C6: Uses non-root USER" "$(grep -q '^USER' $DOCKERFILE && echo true || echo false)"
else
    check "C5: Dockerfile.agent exists" "false"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SECTION D: SAFETY CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
section "SECTION D: SAFETY CONFIGURATION"

CLAUDE_MD=""
[ -f LOCKED/CLAUDE.md ] && CLAUDE_MD="LOCKED/CLAUDE.md"
[ -f .claude/CLAUDE.md ] && CLAUDE_MD=".claude/CLAUDE.md"

if [ -n "$CLAUDE_MD" ]; then
    # Count forbidden operations
    FORBIDDEN_COUNT=$(grep -c "❌" "$CLAUDE_MD" 2>/dev/null || echo "0")
    check "D1: Forbidden operations defined ($FORBIDDEN_COUNT found)" "$([ $FORBIDDEN_COUNT -ge 50 ] && echo true || echo false)"
    
    check "D2: Stop conditions defined" "$(grep -qi 'stop.*condition\|STUCK' $CLAUDE_MD && echo true || echo false)"
    check "D3: Token budget mentioned" "$(grep -qi 'token.*budget\|200000' $CLAUDE_MD && echo true || echo false)"
    check "D4: Max iterations defined" "$(grep -qi 'max.*iteration\|25' $CLAUDE_MD && echo true || echo false)"
else
    check "D1: CLAUDE.md exists" "false"
fi

# Check merge-watcher for safety
WATCHER=""
[ -f LOCKED/scripts/merge-watcher.sh ] && WATCHER="LOCKED/scripts/merge-watcher.sh"
[ -f scripts/merge-watcher.sh ] && WATCHER="scripts/merge-watcher.sh"

if [ -n "$WATCHER" ]; then
    check "D5: Kill switch implemented" "$(grep -qi 'kill.*switch\|EMERGENCY.*STOP' $WATCHER && echo true || echo false)"
    check "D6: Stuck detection implemented" "$(grep -qi 'stuck\|STUCK_THRESHOLD' $WATCHER && echo true || echo false)"
    check "D7: Slack notifications" "$(grep -qi 'slack\|notify' $WATCHER && echo true || echo false)"
else
    check "D5: merge-watcher.sh exists" "false"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SECTION E: STORY VALIDATION
# ─────────────────────────────────────────────────────────────────────────────
section "SECTION E: STORY VALIDATION"

STORY_ERRORS=0
STORIES_CHECKED=0

for story in $(find CONFIGURABLE/stories -name "*.json" 2>/dev/null); do
    ((STORIES_CHECKED++)) || true
    STORY_NAME=$(basename "$story")
    
    # Check required fields
    if ! jq -e '.id' "$story" > /dev/null 2>&1; then
        echo -e "${RED}  ❌ $STORY_NAME: missing 'id'${NC}"
        ((STORY_ERRORS++)) || true
        continue
    fi
    
    if ! jq -e '.title' "$story" > /dev/null 2>&1; then
        echo -e "${RED}  ❌ $STORY_NAME: missing 'title'${NC}"
        ((STORY_ERRORS++)) || true
        continue
    fi
    
    if ! jq -e '.acceptance_criteria | length >= 3' "$story" > /dev/null 2>&1; then
        echo -e "${YELLOW}  ⚠️  $STORY_NAME: less than 3 acceptance criteria${NC}"
        ((WARN++)) || true
    fi
    
    if ! jq -e '.files.forbidden | length >= 1' "$story" > /dev/null 2>&1; then
        echo -e "${YELLOW}  ⚠️  $STORY_NAME: no forbidden files defined${NC}"
        ((WARN++)) || true
    fi
    
    if ! jq -e '.safety.stop_conditions | length >= 3' "$story" > /dev/null 2>&1; then
        echo -e "${YELLOW}  ⚠️  $STORY_NAME: less than 3 stop conditions${NC}"
        ((WARN++)) || true
    fi
    
    echo -e "${GREEN}  ✅ $STORY_NAME: valid${NC}"
done

check "E1: All stories valid ($STORIES_CHECKED checked)" "$([ $STORY_ERRORS -eq 0 ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION F: OPTIONAL INTEGRATIONS
# ─────────────────────────────────────────────────────────────────────────────
section "SECTION F: OPTIONAL INTEGRATIONS"

check "F1: SLACK_WEBHOOK_URL set" "$([ -n \"$SLACK_WEBHOOK_URL\" ] && echo true || echo false)" false
check "F2: GITHUB_TOKEN set" "$([ -n \"$GITHUB_TOKEN\" ] && echo true || echo false)" false
check "F3: GITHUB_REPO set" "$([ -n \"$GITHUB_REPO\" ] && echo true || echo false)" false
check "F4: SUPABASE_URL set" "$([ -n \"$SUPABASE_URL\" ] && echo true || echo false)" false

# ─────────────────────────────────────────────────────────────────────────────
# RESULTS SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  VALIDATION RESULTS"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "  ${GREEN}✅ Passed: $PASS${NC}"
echo -e "  ${RED}❌ Failed: $FAIL${NC}"
echo -e "  ${YELLOW}⚠️  Warnings: $WARN${NC}"
echo ""

SCORE=$(echo "scale=1; ($PASS * 100) / $TOTAL" | bc)
echo "  Score: $PASS/$TOTAL ($SCORE%)"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════"
    echo "  ✅ VALIDATION PASSED - Ready for execution"
    echo "════════════════════════════════════════════════════════════════════════════${NC}"
    exit 0
else
    echo -e "${RED}════════════════════════════════════════════════════════════════════════════"
    echo "  ❌ VALIDATION FAILED - Fix $FAIL issue(s) before execution"
    echo "════════════════════════════════════════════════════════════════════════════${NC}"
    exit 1
fi
