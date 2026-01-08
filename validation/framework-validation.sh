#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# FRAMEWORK VALIDATION V11.0.0
# Comprehensive check of MAF V11 framework structure
# ════════════════════════════════════════════════════════════════════════════
# 
# This validates the FRAMEWORK ITSELF, not a test package.
# Run from maf-v11/ directory: ./validation/framework-validation.sh
#
# ════════════════════════════════════════════════════════════════════════════

VERSION="11.0.0"
FRAMEWORK_DIR="${1:-$(pwd)}"

cd "$FRAMEWORK_DIR" || { echo "❌ Cannot access $FRAMEWORK_DIR"; exit 1; }

echo "════════════════════════════════════════════════════════════════════════════"
echo "  🔬 MAF V11.0.0 FRAMEWORK VALIDATION"
echo "════════════════════════════════════════════════════════════════════════════"
echo "Framework: $FRAMEWORK_DIR"
echo "Date: $(date)"
echo ""

PASS=0
FAIL=0
TOTAL=0

check() {
    local name=$1
    local result=$2
    
    ((TOTAL++)) || true
    
    if [ "$result" = "true" ]; then
        echo "✅ $name"
        ((PASS++)) || true
    else
        echo "❌ $name"
        ((FAIL++)) || true
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: CORE FRAMEWORK FILES
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SECTION 1: CORE FRAMEWORK FILES ==="

check "README.md exists" "$([ -f README.md ] && echo true || echo false)"
check "core/ directory exists" "$([ -d core ] && echo true || echo false)"
check "core/SAFETY-PROTOCOL.md exists" "$([ -f core/SAFETY-PROTOCOL.md ] && echo true || echo false)"
check "core/GATE-SYSTEM.md exists" "$([ -f core/GATE-SYSTEM.md ] && echo true || echo false)"
check "core/APPROVAL-LEVELS.md exists" "$([ -f core/APPROVAL-LEVELS.md ] && echo true || echo false)"
check "core/EMERGENCY-LEVELS.md exists" "$([ -f core/EMERGENCY-LEVELS.md ] && echo true || echo false)"
check "core/FMEA.md exists" "$([ -f core/FMEA.md ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: CORE CONTENT VALIDATION
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SECTION 2: CORE CONTENT VALIDATION ==="

# Count forbidden operations in SAFETY-PROTOCOL.md
if [ -f core/SAFETY-PROTOCOL.md ]; then
    FORBIDDEN_COUNT=$(grep -c "❌" core/SAFETY-PROTOCOL.md 2>/dev/null || echo "0")
    check "SAFETY-PROTOCOL has 100+ forbidden ops ($FORBIDDEN_COUNT)" "$([ $FORBIDDEN_COUNT -ge 100 ] && echo true || echo false)"
fi

# Count gates in GATE-SYSTEM.md
if [ -f core/GATE-SYSTEM.md ]; then
    GATE_COUNT=$(grep -c "## Gate" core/GATE-SYSTEM.md 2>/dev/null || echo "0")
    check "GATE-SYSTEM defines 8+ gates ($GATE_COUNT)" "$([ $GATE_COUNT -ge 8 ] && echo true || echo false)"
fi

# Count approval levels (L0-L5 mentioned in document)
if [ -f core/APPROVAL-LEVELS.md ]; then
    LEVEL_COUNT=$(grep -c "| L[0-5]" core/APPROVAL-LEVELS.md 2>/dev/null || echo "0")
    check "APPROVAL-LEVELS defines L0-L5 ($LEVEL_COUNT refs)" "$([ $LEVEL_COUNT -ge 6 ] && echo true || echo false)"
fi

# Count emergency levels
if [ -f core/EMERGENCY-LEVELS.md ]; then
    EMERGENCY_COUNT=$(grep -c "## E[1-5]" core/EMERGENCY-LEVELS.md 2>/dev/null || echo "0")
    check "EMERGENCY-LEVELS defines 5 levels ($EMERGENCY_COUNT)" "$([ $EMERGENCY_COUNT -ge 5 ] && echo true || echo false)"
fi

# Count FMEA failure modes
if [ -f core/FMEA.md ]; then
    FMEA_COUNT=$(grep -c "| \*\*F" core/FMEA.md 2>/dev/null || echo "0")
    check "FMEA defines 15+ failure modes ($FMEA_COUNT)" "$([ $FMEA_COUNT -ge 15 ] && echo true || echo false)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: TEMPLATE STRUCTURE
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SECTION 3: TEMPLATE STRUCTURE ==="

check "templates/ directory exists" "$([ -d templates ] && echo true || echo false)"
check "templates/story.template.json exists" "$([ -f templates/story.template.json ] && echo true || echo false)"
check "templates/test-template/ exists" "$([ -d templates/test-template ] && echo true || echo false)"

# LOCKED structure
check "templates/test-template/LOCKED/ exists" "$([ -d templates/test-template/LOCKED ] && echo true || echo false)"
check "LOCKED/CLAUDE.md exists" "$([ -f templates/test-template/LOCKED/CLAUDE.md ] && echo true || echo false)"
check "LOCKED/docker-compose.yml exists" "$([ -f templates/test-template/LOCKED/docker-compose.yml ] && echo true || echo false)"
check "LOCKED/Dockerfile.agent exists" "$([ -f templates/test-template/LOCKED/Dockerfile.agent ] && echo true || echo false)"
check "LOCKED/scripts/ exists" "$([ -d templates/test-template/LOCKED/scripts ] && echo true || echo false)"
check "LOCKED/scripts/merge-watcher.sh exists" "$([ -f templates/test-template/LOCKED/scripts/merge-watcher.sh ] && echo true || echo false)"
check "LOCKED/scripts/entrypoint.sh exists" "$([ -f templates/test-template/LOCKED/scripts/entrypoint.sh ] && echo true || echo false)"

# CONFIGURABLE structure
check "templates/test-template/CONFIGURABLE/ exists" "$([ -d templates/test-template/CONFIGURABLE ] && echo true || echo false)"
check "CONFIGURABLE/.env.template exists" "$([ -f templates/test-template/CONFIGURABLE/.env.template ] && echo true || echo false)"
check "CONFIGURABLE/config.json exists" "$([ -f templates/test-template/CONFIGURABLE/config.json ] && echo true || echo false)"
check "CONFIGURABLE/stories/ exists" "$([ -d templates/test-template/CONFIGURABLE/stories ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: VALIDATION TOOLS
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SECTION 4: VALIDATION TOOLS ==="

check "validation/ directory exists" "$([ -d validation ] && echo true || echo false)"
check "validation/pm-validator-v6.0.sh exists" "$([ -f validation/pm-validator-v6.0.sh ] && echo true || echo false)"
check "validation/smoke-test.sh exists" "$([ -f validation/smoke-test.sh ] && echo true || echo false)"
check "validation/protocol-compliance.sh exists" "$([ -f validation/protocol-compliance.sh ] && echo true || echo false)"
check "validation/safety-detector.sh exists" "$([ -f validation/safety-detector.sh ] && echo true || echo false)"
check "validation/generate-report.sh exists" "$([ -f validation/generate-report.sh ] && echo true || echo false)"

# Check scripts are executable
check "pm-validator-v6.0.sh is executable" "$([ -x validation/pm-validator-v6.0.sh ] && echo true || echo false)"
check "smoke-test.sh is executable" "$([ -x validation/smoke-test.sh ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: OPERATIONS DOCUMENTATION
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SECTION 5: OPERATIONS DOCUMENTATION ==="

check "operations/ directory exists" "$([ -d operations ] && echo true || echo false)"
check "operations/DEPLOYMENT.md exists" "$([ -f operations/DEPLOYMENT.md ] && echo true || echo false)"
check "operations/AUTHENTICATION.md exists" "$([ -f operations/AUTHENTICATION.md ] && echo true || echo false)"
check "operations/MONITORING.md exists" "$([ -f operations/MONITORING.md ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: DATABASE SCHEMA
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SECTION 6: DATABASE SCHEMA ==="

check "database/ directory exists" "$([ -d database ] && echo true || echo false)"
check "database/schema/ directory exists" "$([ -d database/schema ] && echo true || echo false)"
check "001-maf-v11-core.sql exists" "$([ -f database/schema/001-maf-v11-core.sql ] && echo true || echo false)"
check "002-maf-v11-seed-data.sql exists" "$([ -f database/schema/002-maf-v11-seed-data.sql ] && echo true || echo false)"
check "database/helpers/maf-db.ts exists" "$([ -f database/helpers/maf-db.ts ] && echo true || echo false)"

# Check schema content
if [ -f database/schema/001-maf-v11-core.sql ]; then
    TABLE_COUNT=$(grep -c "CREATE TABLE" database/schema/001-maf-v11-core.sql 2>/dev/null || echo "0")
    check "Schema defines 6 tables ($TABLE_COUNT)" "$([ $TABLE_COUNT -ge 6 ] && echo true || echo false)"
    
    VIEW_COUNT=$(grep -c "CREATE.*VIEW" database/schema/001-maf-v11-core.sql 2>/dev/null || echo "0")
    check "Schema defines 3 views ($VIEW_COUNT)" "$([ $VIEW_COUNT -ge 3 ] && echo true || echo false)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: PROJECT CONFIGURATION
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SECTION 7: PROJECT CONFIGURATION ==="

check "projects/ directory exists" "$([ -d projects ] && echo true || echo false)"
check "projects/airview/ exists" "$([ -d projects/airview ] && echo true || echo false)"
check "projects/airview/AGENTS.md exists" "$([ -f projects/airview/AGENTS.md ] && echo true || echo false)"
check "projects/airview/DOMAINS.md exists" "$([ -f projects/airview/DOMAINS.md ] && echo true || echo false)"
check "projects/_template/ exists" "$([ -d projects/_template ] && echo true || echo false)"

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 8: SOURCE TRACEABILITY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "=== SECTION 8: SOURCE TRACEABILITY ==="

# Check core files have source traceability headers
for file in core/*.md; do
    if [ -f "$file" ]; then
        HAS_TRACE=$(grep -c "SOURCE TRACEABILITY" "$file" 2>/dev/null || echo "0")
        BASENAME=$(basename "$file")
        check "$BASENAME has traceability header" "$([ $HAS_TRACE -gt 0 ] && echo true || echo false)"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# RESULTS
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "  VALIDATION RESULTS"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "  ✅ Passed: $PASS"
echo "  ❌ Failed: $FAIL"
echo "  📊 Total:  $TOTAL"
echo ""

SCORE=$(echo "scale=1; ($PASS * 100) / $TOTAL" | bc 2>/dev/null || echo "N/A")
echo "  Score: $PASS/$TOTAL ($SCORE%)"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "════════════════════════════════════════════════════════════════════════════"
    echo "  ✅ MAF V11.0.0 FRAMEWORK VALIDATED SUCCESSFULLY"
    echo "════════════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo "════════════════════════════════════════════════════════════════════════════"
    echo "  ❌ VALIDATION FAILED - $FAIL issue(s) found"
    echo "════════════════════════════════════════════════════════════════════════════"
    exit 1
fi
