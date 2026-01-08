#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# GENERATE REPORT V11.0.0 - CREATE VALIDATION REPORT
# ════════════════════════════════════════════════════════════════════════════
# SOURCE TRACEABILITY:
#   - /mnt/project/MULTI-AGENT-VALIDATION-CHECKLIST.md
#
# Purpose: Generate a comprehensive validation report for test packages
# Output: VALIDATION-REPORT-[timestamp].md
# ════════════════════════════════════════════════════════════════════════════

VERSION="11.0.0"
PACKAGE_DIR="${1:-.}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_FILE="VALIDATION-REPORT-$TIMESTAMP.md"

cd "$PACKAGE_DIR" || { echo "❌ Cannot access $PACKAGE_DIR"; exit 1; }

# Load .env if exists
[ -f .env ] && source .env 2>/dev/null

echo "════════════════════════════════════════════════════════════════════════════"
echo "  📊 GENERATING VALIDATION REPORT"
echo "════════════════════════════════════════════════════════════════════════════"

cat > "$REPORT_FILE" << EOF
# MAF V11.0.0 VALIDATION REPORT

**Generated:** $(date)  
**Package:** $(pwd)  
**Report ID:** $TIMESTAMP

---

## Executive Summary

| Metric | Value |
|--------|-------|
| Validation Date | $(date) |
| Package Path | $(pwd) |
| MAF Version | V11.0.0 |

---

## Section A: Environment Check

| Check | Status |
|-------|--------|
| Docker Running | $(docker info > /dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL") |
| Docker Compose | $(docker compose version > /dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL") |
| .env File | $([ -f .env ] && echo "✅ EXISTS" || echo "❌ MISSING") |
| ANTHROPIC_API_KEY | $([ -n "$ANTHROPIC_API_KEY" ] && echo "✅ SET" || echo "❌ NOT SET") |
| Network | $(curl -s --max-time 5 https://api.anthropic.com > /dev/null 2>&1 && echo "✅ OK" || echo "⚠️ UNREACHABLE") |

---

## Section B: MAF Structure

### LOCKED Files (Framework - Never Modify)

| File | Status |
|------|--------|
| LOCKED/CLAUDE.md | $([ -f LOCKED/CLAUDE.md ] && echo "✅ EXISTS" || echo "❌ MISSING") |
| LOCKED/docker-compose.yml | $([ -f LOCKED/docker-compose.yml ] && echo "✅ EXISTS" || echo "❌ MISSING") |
| LOCKED/Dockerfile.agent | $([ -f LOCKED/Dockerfile.agent ] && echo "✅ EXISTS" || echo "❌ MISSING") |
| LOCKED/scripts/merge-watcher.sh | $([ -f LOCKED/scripts/merge-watcher.sh ] && echo "✅ EXISTS" || echo "❌ MISSING") |
| LOCKED/scripts/entrypoint.sh | $([ -f LOCKED/scripts/entrypoint.sh ] && echo "✅ EXISTS" || echo "❌ MISSING") |

### CONFIGURABLE Files (Your Test Config)

| File | Status |
|------|--------|
| CONFIGURABLE/config.json | $([ -f CONFIGURABLE/config.json ] && echo "✅ EXISTS" || echo "❌ MISSING") |
| CONFIGURABLE/stories/ | $([ -d CONFIGURABLE/stories ] && echo "✅ EXISTS" || echo "❌ MISSING") |

---

## Section C: Story Inventory

EOF

# Add story list
echo "### Stories Found" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Wave | Story ID | Title |" >> "$REPORT_FILE"
echo "|------|----------|-------|" >> "$REPORT_FILE"

for wave_dir in CONFIGURABLE/stories/wave*/; do
    [ -d "$wave_dir" ] || continue
    WAVE=$(basename "$wave_dir")
    
    for story in "$wave_dir"*.json; do
        [ -f "$story" ] || continue
        STORY_ID=$(jq -r '.id // "N/A"' "$story" 2>/dev/null)
        TITLE=$(jq -r '.title // "N/A"' "$story" 2>/dev/null | head -c 50)
        echo "| $WAVE | $STORY_ID | $TITLE |" >> "$REPORT_FILE"
    done
done

cat >> "$REPORT_FILE" << EOF

---

## Section D: Safety Configuration

### Forbidden Operations Count

EOF

if [ -f "LOCKED/CLAUDE.md" ]; then
    FORBIDDEN=$(grep -c "❌" LOCKED/CLAUDE.md 2>/dev/null || echo "0")
    echo "- CLAUDE.md: **$FORBIDDEN** forbidden operations defined" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

### Safety Limits (from config.json)

EOF

if [ -f "CONFIGURABLE/config.json" ]; then
    MAX_ITER=$(jq -r '.safety.max_iterations_per_story // 25' CONFIGURABLE/config.json 2>/dev/null)
    TOKEN_BUDGET=$(jq -r '.safety.token_budget_per_story // 200000' CONFIGURABLE/config.json 2>/dev/null)
    TIMEOUT=$(jq -r '.safety.timeout_minutes_per_story // 120' CONFIGURABLE/config.json 2>/dev/null)
    STUCK=$(jq -r '.safety.stuck_threshold_minutes // 30' CONFIGURABLE/config.json 2>/dev/null)
    
    echo "| Limit | Value |" >> "$REPORT_FILE"
    echo "|-------|-------|" >> "$REPORT_FILE"
    echo "| Max Iterations | $MAX_ITER |" >> "$REPORT_FILE"
    echo "| Token Budget | $TOKEN_BUDGET |" >> "$REPORT_FILE"
    echo "| Timeout (min) | $TIMEOUT |" >> "$REPORT_FILE"
    echo "| Stuck Threshold (min) | $STUCK |" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## Section E: Docker Configuration

EOF

COMPOSE=""
[ -f "LOCKED/docker-compose.yml" ] && COMPOSE="LOCKED/docker-compose.yml"
[ -f "docker-compose.yml" ] && COMPOSE="docker-compose.yml"

if [ -n "$COMPOSE" ]; then
    echo "| Check | Status |" >> "$REPORT_FILE"
    echo "|-------|--------|" >> "$REPORT_FILE"
    echo "| Valid YAML | $(docker compose -f $COMPOSE config > /dev/null 2>&1 && echo "✅" || echo "❌") |" >> "$REPORT_FILE"
    echo "| service_completed_successfully | $(grep -q 'service_completed_successfully' $COMPOSE && echo "✅" || echo "❌") |" >> "$REPORT_FILE"
    echo "| --dangerously-skip-permissions | $(grep -q '\-\-dangerously-skip-permissions' $COMPOSE && echo "✅" || echo "❌") |" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## Conclusion

This report was generated by MAF V11.0.0 validation tools.

**Next Steps:**
1. Review any ❌ items above
2. Fix issues before execution
3. Run \`pm-validator-v6.0.sh\` for detailed validation

---

*Generated by generate-report.sh V$VERSION*
EOF

echo ""
echo "✅ Report generated: $REPORT_FILE"
echo ""

# Show summary
PASS_COUNT=$(grep -c "✅" "$REPORT_FILE" || echo "0")
FAIL_COUNT=$(grep -c "❌" "$REPORT_FILE" || echo "0")

echo "Summary: $PASS_COUNT passed, $FAIL_COUNT failed"
