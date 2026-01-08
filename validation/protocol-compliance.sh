#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# PROTOCOL COMPLIANCE V11.0.0 - MAF STRUCTURE VERIFICATION
# ════════════════════════════════════════════════════════════════════════════
# SOURCE TRACEABILITY:
#   - /mnt/project/MULTI-AGENT-VALIDATION-CHECKLIST.md
#   - /mnt/project/WORKFLOW-V4_3-VALIDATION-CHECKLIST.md
#
# Purpose: Verify test package follows MAF V11.0.0 protocol
# Checks: LOCKED integrity, CONFIGURABLE structure, safety requirements
# ════════════════════════════════════════════════════════════════════════════

VERSION="11.0.0"
PACKAGE_DIR="${1:-.}"

cd "$PACKAGE_DIR" || { echo "❌ Cannot access $PACKAGE_DIR"; exit 1; }

echo "════════════════════════════════════════════════════════════════════════════"
echo "  📋 PROTOCOL COMPLIANCE V11.0.0"
echo "════════════════════════════════════════════════════════════════════════════"
echo "Package: $(pwd)"
echo ""

PASS=0
FAIL=0

check() {
    local name=$1
    local result=$2
    
    if [ "$result" = "true" ]; then
        echo "✅ $name"
        ((PASS++)) || true
    else
        echo "❌ $name"
        ((FAIL++)) || true
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: LOCKED FILES INTEGRITY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== LOCKED FILES INTEGRITY ==="

# These files should NOT be modified from template
LOCKED_FILES=(
    "LOCKED/CLAUDE.md"
    "LOCKED/docker-compose.yml"
    "LOCKED/Dockerfile.agent"
    "LOCKED/scripts/merge-watcher.sh"
    "LOCKED/scripts/entrypoint.sh"
)

for file in "${LOCKED_FILES[@]}"; do
    check "LOCKED: $file exists" "$([ -f $file ] && echo true || echo false)"
done

# Check CLAUDE.md has forbidden operations
if [ -f "LOCKED/CLAUDE.md" ]; then
    FORBIDDEN_COUNT=$(grep -c "❌" LOCKED/CLAUDE.md 2>/dev/null || echo "0")
    check "CLAUDE.md has 50+ forbidden ops ($FORBIDDEN_COUNT)" "$([ $FORBIDDEN_COUNT -ge 50 ] && echo true || echo false)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: CONFIGURABLE STRUCTURE
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== CONFIGURABLE STRUCTURE ==="

check "CONFIGURABLE/.env.template or .env exists" "$([ -f CONFIGURABLE/.env.template ] || [ -f .env ] && echo true || echo false)"
check "CONFIGURABLE/config.json exists" "$([ -f CONFIGURABLE/config.json ] && echo true || echo false)"
check "CONFIGURABLE/stories/ exists" "$([ -d CONFIGURABLE/stories ] && echo true || echo false)"

# Check for wave directories
WAVE_COUNT=0
for dir in CONFIGURABLE/stories/wave*/; do
    [ -d "$dir" ] && ((WAVE_COUNT++)) || true
done
check "At least 1 wave directory ($WAVE_COUNT found)" "$([ $WAVE_COUNT -ge 1 ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: STORY COMPLIANCE
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== STORY COMPLIANCE ==="

STORY_COUNT=0
VALID_STORIES=0

for story in $(find CONFIGURABLE/stories -name "*.json" 2>/dev/null); do
    ((STORY_COUNT++)) || true
    
    # Check required fields
    VALID=true
    
    # id field
    if ! jq -e '.id' "$story" > /dev/null 2>&1; then
        VALID=false
    fi
    
    # title field
    if ! jq -e '.title' "$story" > /dev/null 2>&1; then
        VALID=false
    fi
    
    # acceptance_criteria array
    if ! jq -e '.acceptance_criteria | type == "array"' "$story" > /dev/null 2>&1; then
        VALID=false
    fi
    
    # files.forbidden array
    if ! jq -e '.files.forbidden | type == "array"' "$story" > /dev/null 2>&1; then
        VALID=false
    fi
    
    [ "$VALID" = "true" ] && ((VALID_STORIES++)) || true
done

check "Stories found: $STORY_COUNT" "$([ $STORY_COUNT -gt 0 ] && echo true || echo false)"
check "All stories valid: $VALID_STORIES/$STORY_COUNT" "$([ $VALID_STORIES -eq $STORY_COUNT ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: SAFETY REQUIREMENTS
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SAFETY REQUIREMENTS ==="

# Check docker-compose for safety patterns
COMPOSE="LOCKED/docker-compose.yml"
[ ! -f "$COMPOSE" ] && COMPOSE="docker-compose.yml"

if [ -f "$COMPOSE" ]; then
    check "Uses depends_on: service_completed_successfully" "$(grep -q 'service_completed_successfully' $COMPOSE && echo true || echo false)"
    check "Uses --dangerously-skip-permissions" "$(grep -q '\-\-dangerously-skip-permissions' $COMPOSE && echo true || echo false)"
fi

# Check Dockerfile for non-root user
DOCKERFILE="LOCKED/Dockerfile.agent"
[ ! -f "$DOCKERFILE" ] && DOCKERFILE="Dockerfile.agent"

if [ -f "$DOCKERFILE" ]; then
    check "Dockerfile uses non-root USER" "$(grep -q '^USER' $DOCKERFILE && echo true || echo false)"
    check "Dockerfile has no ENTRYPOINT" "$(! grep -q '^ENTRYPOINT' $DOCKERFILE && echo true || echo false)"
fi

# Check merge-watcher for safety
WATCHER="LOCKED/scripts/merge-watcher.sh"
[ ! -f "$WATCHER" ] && WATCHER="scripts/merge-watcher.sh"

if [ -f "$WATCHER" ]; then
    check "Has kill switch" "$(grep -qi 'kill.*switch\|EMERGENCY' $WATCHER && echo true || echo false)"
    check "Has stuck detection" "$(grep -qi 'stuck\|STUCK_THRESHOLD' $WATCHER && echo true || echo false)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: CONFIG VALIDATION
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== CONFIG VALIDATION ==="

CONFIG="CONFIGURABLE/config.json"
if [ -f "$CONFIG" ]; then
    check "config.json is valid JSON" "$(jq . $CONFIG > /dev/null 2>&1 && echo true || echo false)"
    
    # Check safety limits
    MAX_ITER=$(jq -r '.safety.max_iterations_per_story // 25' $CONFIG 2>/dev/null)
    TOKEN_BUDGET=$(jq -r '.safety.token_budget_per_story // 200000' $CONFIG 2>/dev/null)
    TIMEOUT=$(jq -r '.safety.timeout_minutes_per_story // 120' $CONFIG 2>/dev/null)
    
    check "max_iterations <= 50 ($MAX_ITER)" "$([ $MAX_ITER -le 50 ] && echo true || echo false)"
    check "token_budget <= 500000 ($TOKEN_BUDGET)" "$([ $TOKEN_BUDGET -le 500000 ] && echo true || echo false)"
    check "timeout_minutes <= 240 ($TIMEOUT)" "$([ $TIMEOUT -le 240 ] && echo true || echo false)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# RESULTS
# ─────────────────────────────────────────────────────────────────────────────
TOTAL=$((PASS + FAIL))
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  COMPLIANCE RESULTS: $PASS/$TOTAL passed"
echo "════════════════════════════════════════════════════════════════════════════"

if [ $FAIL -eq 0 ]; then
    echo "  ✅ COMPLIANT - Package follows MAF V11.0.0 protocol"
    exit 0
else
    echo "  ❌ NON-COMPLIANT - $FAIL issues found"
    exit 1
fi
