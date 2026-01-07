#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# PM VALIDATOR V5.6 - SECTIONS R & S ADDITION
# Rollback System Validation + Safety Protocol Validation
# ═══════════════════════════════════════════════════════════════════════════════
# Version: 5.6.0
# Date: January 7, 2026
# Extends: PM Validator V5.5 + MAF Gap Analysis Requirements
# New Sections: R (Rollback), S (Safety)
# ═══════════════════════════════════════════════════════════════════════════════

# Copy this entire section to the END of pm-validator-v5_5.sh
# Place BEFORE the "FINAL REPORT" section

# ───────────────────────────────────────────────────────────────────────────────
# SECTION R: ROLLBACK SYSTEM VALIDATION (MAF Gap 2)
# Validates rollback capabilities for autonomous agent recovery
# ───────────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ SECTION R: ROLLBACK SYSTEM VALIDATION ═══"

# R1: Check for ROLLBACK-PLAN.md template
if [ -f "templates/ROLLBACK-PLAN.md.template" ] || [ -f "ROLLBACK-PLAN.md.template" ] || [ -f ".claude/templates/ROLLBACK-PLAN.md" ]; then
    check "R1: ROLLBACK-PLAN.md template exists" "true"
else
    check "R1: ROLLBACK-PLAN.md template exists" "false"
fi

# R2: Check for START.md template
if [ -f "templates/START.md.template" ] || [ -f "START.md.template" ] || [ -f ".claude/templates/START.md" ]; then
    check "R2: START.md template exists" "true"
else
    check "R2: START.md template exists" "false"
fi

# R3: Check for rollback helpers (TypeScript)
ROLLBACK_HELPERS=""
[ -f "lib/rollback-helpers.ts" ] && ROLLBACK_HELPERS="lib/rollback-helpers.ts"
[ -f "src/lib/rollback-helpers.ts" ] && ROLLBACK_HELPERS="src/lib/rollback-helpers.ts"
[ -f "lib/agents/rollback-helpers.ts" ] && ROLLBACK_HELPERS="lib/agents/rollback-helpers.ts"

if [ -n "$ROLLBACK_HELPERS" ]; then
    check "R3: Rollback helpers TypeScript file exists" "true"
    
    # R4: Check for createRollbackCheckpoint function
    if grep -q "createRollbackCheckpoint" "$ROLLBACK_HELPERS" 2>/dev/null; then
        check "R4: createRollbackCheckpoint function defined" "true"
    else
        check "R4: createRollbackCheckpoint function defined" "false"
    fi
    
    # R5: Check for executeStoryWithRollback wrapper
    if grep -q "executeStoryWithRollback" "$ROLLBACK_HELPERS" 2>/dev/null; then
        check "R5: executeStoryWithRollback wrapper defined" "true"
    else
        check "R5: executeStoryWithRollback wrapper defined" "false"
    fi
else
    check "R3: Rollback helpers TypeScript file exists" "false"
    check "R4: createRollbackCheckpoint function defined" "false"
    check "R5: executeStoryWithRollback wrapper defined" "false"
fi

# R6: Check for rollback_history table in migrations
MIGRATION_DIR=""
[ -d "supabase/migrations" ] && MIGRATION_DIR="supabase/migrations"
[ -d "migrations" ] && MIGRATION_DIR="migrations"
[ -d "prisma/migrations" ] && MIGRATION_DIR="prisma/migrations"

if [ -n "$MIGRATION_DIR" ]; then
    if grep -rq "rollback_history" "$MIGRATION_DIR" 2>/dev/null; then
        check "R6: rollback_history table in migrations" "true"
    else
        check "R6: rollback_history table in migrations" "false"
    fi
else
    # Check for maf-complete-migration.sql
    if grep -q "rollback_history" maf-complete-migration.sql 2>/dev/null; then
        check "R6: rollback_history table in migrations" "true"
    else
        check "R6: rollback_history table in migrations" "false"
    fi
fi

# R7: Check for agent_errors table in migrations
if [ -n "$MIGRATION_DIR" ]; then
    if grep -rq "agent_errors" "$MIGRATION_DIR" 2>/dev/null; then
        check "R7: agent_errors table in migrations" "true"
    else
        check "R7: agent_errors table in migrations" "false"
    fi
else
    if grep -q "agent_errors" maf-complete-migration.sql 2>/dev/null; then
        check "R7: agent_errors table in migrations" "true"
    else
        check "R7: agent_errors table in migrations" "false"
    fi
fi

# R8: Check for Git worktree support in setup scripts
WORKTREE_SETUP=""
if grep -rq "git worktree" scripts/*.sh 2>/dev/null; then
    check "R8: Git worktree commands in setup scripts" "true"
elif grep -rq "git worktree" *.sh 2>/dev/null; then
    check "R8: Git worktree commands in setup scripts" "true"
else
    check "R8: Git worktree commands in setup scripts" "false"
fi

# R9: Check for emergency rollback function
if [ -n "$MIGRATION_DIR" ]; then
    if grep -rq "emergency_wave_rollback\|emergencyRollback" "$MIGRATION_DIR" 2>/dev/null; then
        check "R9: Emergency rollback function defined" "true"
    else
        check "R9: Emergency rollback function defined" "false"
    fi
else
    if grep -q "emergency_wave_rollback\|emergencyRollback" maf-complete-migration.sql 2>/dev/null; then
        check "R9: Emergency rollback function defined" "true"
    else
        check "R9: Emergency rollback function defined" "false"
    fi
fi

# R10: Check for stuck detection in agent sessions
if grep -rq "stuck_detected_at\|consecutive_same_error" "$MIGRATION_DIR" maf-complete-migration.sql 2>/dev/null; then
    check "R10: Stuck detection columns in agent_sessions" "true"
else
    check "R10: Stuck detection columns in agent_sessions" "false"
fi

# ───────────────────────────────────────────────────────────────────────────────
# SECTION S: SAFETY PROTOCOL VALIDATION (MAF Gap 3)
# Validates safety measures for autonomous agent execution
# ───────────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ SECTION S: SAFETY PROTOCOL VALIDATION ═══"

# Find CLAUDE.md file
CLAUDE_MD=""
[ -f "CLAUDE.md" ] && CLAUDE_MD="CLAUDE.md"
[ -f ".claude/CLAUDE.md" ] && CLAUDE_MD=".claude/CLAUDE.md"
[ -f "docs/CLAUDE.md" ] && CLAUDE_MD="docs/CLAUDE.md"

if [ -n "$CLAUDE_MD" ]; then
    check "S1: CLAUDE.md file exists" "true"
    
    # S2: Check for forbidden operations section
    if grep -q "FORBIDDEN\|forbidden operations\|NEVER" "$CLAUDE_MD" 2>/dev/null; then
        check "S2: Forbidden operations section exists" "true"
    else
        check "S2: Forbidden operations section exists" "false"
    fi
    
    # S3: Check for database destruction prevention
    if grep -q "DROP DATABASE\|DROP TABLE\|TRUNCATE" "$CLAUDE_MD" 2>/dev/null; then
        check "S3: Database destruction commands listed" "true"
    else
        check "S3: Database destruction commands listed" "false"
    fi
    
    # S4: Check for file system destruction prevention
    if grep -q "rm -rf\|rm -r /" "$CLAUDE_MD" 2>/dev/null; then
        check "S4: File system destruction commands listed" "true"
    else
        check "S4: File system destruction commands listed" "false"
    fi
    
    # S5: Check for git force push prevention
    if grep -q "git push --force\|git push -f\|force-push\|--force" "$CLAUDE_MD" 2>/dev/null; then
        check "S5: Git force push prevention documented" "true"
    else
        check "S5: Git force push prevention documented" "false"
    fi
    
    # S6: Check for privilege escalation prevention
    if grep -q "sudo\|chmod 777\|chown root" "$CLAUDE_MD" 2>/dev/null; then
        check "S6: Privilege escalation prevention documented" "true"
    else
        check "S6: Privilege escalation prevention documented" "false"
    fi
    
    # S7: Check for secrets protection
    if grep -q "\.env\|API_KEY\|credentials\|secrets" "$CLAUDE_MD" 2>/dev/null; then
        check "S7: Secrets protection documented" "true"
    else
        check "S7: Secrets protection documented" "false"
    fi
    
    # S8: Check for emergency stop levels (E1-E5)
    if grep -q "E1\|E2\|E3\|E4\|E5\|Emergency\|EMERGENCY" "$CLAUDE_MD" 2>/dev/null; then
        check "S8: Emergency stop levels documented" "true"
    else
        check "S8: Emergency stop levels documented" "false"
    fi
    
    # S9: Check for 8-gate system documentation
    if grep -q "Gate 0\|Gate 7\|8-gate\|8 gate" "$CLAUDE_MD" 2>/dev/null; then
        check "S9: 8-gate system documented" "true"
    else
        check "S9: 8-gate system documented" "false"
    fi
    
    # S10: Check for CTO-only merge authority
    if grep -q "CTO ONLY\|cto only\|only CTO\|ONLY.*merge" "$CLAUDE_MD" 2>/dev/null; then
        check "S10: CTO-only merge authority documented" "true"
    else
        check "S10: CTO-only merge authority documented" "false"
    fi
else
    check "S1: CLAUDE.md file exists" "false"
    check "S2: Forbidden operations section exists" "false"
    check "S3: Database destruction commands listed" "false"
    check "S4: File system destruction commands listed" "false"
    check "S5: Git force push prevention documented" "false"
    check "S6: Privilege escalation prevention documented" "false"
    check "S7: Secrets protection documented" "false"
    check "S8: Emergency stop levels documented" "false"
    check "S9: 8-gate system documented" "false"
    check "S10: CTO-only merge authority documented" "false"
fi

# S11: Check for domain isolation (DOMAINS.md)
if [ -f "DOMAINS.md" ] || [ -f ".claude/DOMAINS.md" ] || [ -f "docs/DOMAINS.md" ]; then
    check "S11: DOMAINS.md file exists" "true"
else
    check "S11: DOMAINS.md file exists" "false"
fi

# S12: Check for agent definitions (AGENTS.md)
if [ -f "AGENTS.md" ] || [ -f ".claude/AGENTS.md" ] || [ -f "docs/AGENTS.md" ]; then
    check "S12: AGENTS.md file exists" "true"
else
    check "S12: AGENTS.md file exists" "false"
fi

# S13: Check for ai-story schema with safety fields
SCHEMA_FILE=""
[ -f "ai-story-schema.json" ] && SCHEMA_FILE="ai-story-schema.json"
[ -f "ai-story-schema-v4.json" ] && SCHEMA_FILE="ai-story-schema-v4.json"
[ -f ".claude/ai-story-schema.json" ] && SCHEMA_FILE=".claude/ai-story-schema.json"
[ -f "schemas/ai-story-schema.json" ] && SCHEMA_FILE="schemas/ai-story-schema.json"

if [ -n "$SCHEMA_FILE" ]; then
    check "S13: AI story schema file exists" "true"
    
    # S14: Check for safety section in schema
    if grep -q '"safety"' "$SCHEMA_FILE" 2>/dev/null; then
        check "S14: Safety section in schema" "true"
    else
        check "S14: Safety section in schema" "false"
    fi
    
    # S15: Check for stop_conditions in schema
    if grep -q 'stop_conditions' "$SCHEMA_FILE" 2>/dev/null; then
        check "S15: stop_conditions field in schema" "true"
    else
        check "S15: stop_conditions field in schema" "false"
    fi
    
    # S16: Check for forbidden files in schema
    if grep -q '"forbidden"' "$SCHEMA_FILE" 2>/dev/null; then
        check "S16: files.forbidden field in schema" "true"
    else
        check "S16: files.forbidden field in schema" "false"
    fi
else
    check "S13: AI story schema file exists" "false"
    check "S14: Safety section in schema" "false"
    check "S15: stop_conditions field in schema" "false"
    check "S16: files.forbidden field in schema" "false"
fi

# S17: Check for signal protocol (signals table or helpers)
if grep -rq "signal_type\|send_signal\|SignalType" "$MIGRATION_DIR" maf-complete-migration.sql lib/*.ts src/lib/*.ts 2>/dev/null; then
    check "S17: Signal protocol defined" "true"
else
    check "S17: Signal protocol defined" "false"
fi

# S18: Check for QA independence (qa_reports table)
if grep -rq "qa_reports\|qa_agent\|QAReport" "$MIGRATION_DIR" maf-complete-migration.sql lib/*.ts src/lib/*.ts 2>/dev/null; then
    check "S18: QA reporting system defined" "true"
else
    check "S18: QA reporting system defined" "false"
fi

# S19: Check for production operations protection
if [ -n "$CLAUDE_MD" ]; then
    if grep -q "deploy\|npm publish\|production" "$CLAUDE_MD" 2>/dev/null; then
        check "S19: Production operations protection documented" "true"
    else
        check "S19: Production operations protection documented" "false"
    fi
else
    check "S19: Production operations protection documented" "false"
fi

# S20: Check for cross-domain violation prevention
if [ -n "$CLAUDE_MD" ]; then
    if grep -q "cross-domain\|domain boundary\|DOMAIN" "$CLAUDE_MD" 2>/dev/null; then
        check "S20: Cross-domain violation prevention documented" "true"
    else
        check "S20: Cross-domain violation prevention documented" "false"
    fi
else
    check "S20: Cross-domain violation prevention documented" "false"
fi

# ───────────────────────────────────────────────────────────────────────────────
# SECTION R+S SUMMARY
# ───────────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ SECTION R+S: MAF COMPLIANCE SUMMARY ═══"

R_PASS=0
R_TOTAL=10
S_PASS=0
S_TOTAL=20

# Count R section passes (simplified - actual implementation would track per check)
echo "Section R (Rollback): Check pm-validator output above"
echo "Section S (Safety): Check pm-validator output above"
echo ""
echo "Recommended thresholds:"
echo "  - Section R: 8/10 for production readiness"
echo "  - Section S: 15/20 for production readiness"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# END OF SECTIONS R & S
# Continue with FINAL REPORT section from pm-validator-v5_5.sh
# ═══════════════════════════════════════════════════════════════════════════════
