# MAF MASTER INTEGRATION GUIDE

> **Multi-Agent Framework - Complete Setup & Deployment**  
> **Version:** 1.0  
> **Date:** January 7, 2026  
> **For:** AirView Project

---

## Quick Start (5 Minutes)

```bash
# 1. Copy all MAF files to your project
cp DOMAINS.md AGENTS.md CLAUDE-V2.1.md docs/
cp ai-story-schema-v4.json schemas/
cp START.md.template ROLLBACK-PLAN.md.template templates/
cp signal-helpers.ts src/lib/maf/
cp maf-worktree.sh scripts/
chmod +x scripts/maf-worktree.sh

# 2. Rename CLAUDE.md
cp CLAUDE-V2.1.md CLAUDE.md

# 3. Apply database migration
psql $DATABASE_URL -f maf-complete-migration.sql

# 4. Setup worktrees for all agents
./scripts/maf-worktree.sh setup

# 5. Run PM Validator to verify
cat pm-validator-sections-R-S.sh >> scripts/pm-validator.sh
./scripts/pm-validator.sh
```

---

## File Placement Reference

```
your-project/
├── CLAUDE.md                           # ← CLAUDE-V2.1.md (rename)
├── docs/
│   ├── DOMAINS.md                      # Domain definitions
│   ├── AGENTS.md                       # Agent specifications
│   └── MAF-INTEGRATION.md              # This file
├── schemas/
│   └── ai-story-schema-v4.json         # Story schema
├── templates/
│   ├── START.md.template               # Gate 1 template
│   └── ROLLBACK-PLAN.md.template       # Rollback template
├── src/lib/maf/
│   ├── signal-helpers.ts               # Agent communication
│   └── rollback-helpers.ts             # Rollback functions
├── scripts/
│   ├── maf-worktree.sh                 # Worktree automation
│   └── pm-validator.sh                 # Updated with R+S
└── supabase/migrations/
    └── YYYYMMDD_maf_schema.sql         # Database migration
```

---

## Component Integration Details

### 1. CLAUDE.md (Safety Protocol)

The CLAUDE-V2.1.md file should be renamed to CLAUDE.md at your project root. This is what every agent reads first.

**Key Sections:**
- 108 forbidden operations
- 8-gate workflow
- Emergency stop levels (E1-E5)
- CTO-only merge authority

```bash
# Copy and rename
cp CLAUDE-V2.1.md CLAUDE.md

# Verify forbidden operations count
grep -c "NEVER\|FORBIDDEN" CLAUDE.md  # Should be 100+
```

### 2. Database Migration

The `maf-complete-migration.sql` creates all required tables:

| Table | Purpose |
|-------|---------|
| waves | Project phases/sprints |
| stories | Work items with gate tracking |
| signals | Agent-to-agent communication |
| agent_sessions | Active agent tracking |
| agent_activity | Audit log |
| gate_transitions | Gate history |
| qa_reports | QA validation results |
| rollback_history | Git checkpoints |
| agent_errors | Error memory for approach tracking |

```bash
# Apply to Supabase
psql $DATABASE_URL -f maf-complete-migration.sql

# Verify tables created
psql $DATABASE_URL -c "\dt"
```

### 3. Signal Helpers (TypeScript)

Install the Supabase client and copy the helpers:

```bash
npm install @supabase/supabase-js

# Copy to your lib directory
cp signal-helpers.ts src/lib/maf/
```

**Usage Example:**

```typescript
import { 
  signalReadyForQA, 
  getPendingSignals,
  registerSession 
} from '@/lib/maf/signal-helpers'

// Register agent session
const sessionId = await registerSession({
  agentId: 'fe-auth',
  agentType: 'frontend',
  domain: 'auth',
  waveId: 'wave-uuid'
})

// Signal QA when ready
await signalReadyForQA('fe-auth', 'qa-auth', storyId, {
  branch: 'feature/AUTH-FE-001',
  coverage: 85,
  testsPassed: 24,
  testsTotal: 24
})

// Poll for signals (in QA agent)
const signals = await getPendingSignals('qa-auth')
```

### 4. Worktree Setup

Each agent needs its own isolated workspace:

```bash
# Make executable
chmod +x scripts/maf-worktree.sh

# Setup all 29 agent worktrees
./scripts/maf-worktree.sh setup

# Verify
./scripts/maf-worktree.sh list
```

**Directory Structure Created:**

```
~/worktrees/
├── fe-auth/          # Frontend auth agent
├── fe-client/        # Frontend client agent
├── be-auth/          # Backend auth agent
├── be-client/        # Backend client agent
├── qa-core/          # QA core agent
├── qa-auth/          # QA auth specialist
└── ...               # 29 total
```

### 5. PM Validator Update

Add Sections R & S to your existing PM Validator:

```bash
# Append new sections
cat pm-validator-sections-R-S.sh >> scripts/pm-validator.sh

# Run full validation
./scripts/pm-validator.sh
```

**New Checks Added:**
- R1-R10: Rollback system validation
- S1-S20: Safety protocol validation

---

## Agent Kickstart Workflow

### Starting a New Story

1. **PM Assigns Story:**
```bash
# PM runs in main repo
./scripts/maf-worktree.sh create-story AUTH-FE-001 fe-auth
```

2. **Agent Starts Work:**
```bash
# In agent worktree
cd ~/worktrees/fe-auth/AUTH-FE-001
claude -p "Read CLAUDE.md and START.md, then begin Gate 1"
```

3. **Agent Signals QA:**
```typescript
// After Gate 3 complete
await signalReadyForQA('fe-auth', 'qa-auth', storyId, {
  branch: 'feature/AUTH-FE-001',
  coverage: 85,
  testsPassed: 24,
  testsTotal: 24
})
```

4. **QA Validates:**
```bash
cd ~/worktrees/qa-auth
claude -p "Check signals for ready_for_qa, validate the story"
```

5. **CTO Merges:**
```bash
# Only CTO can merge
cd /main/repo
git merge --no-ff feature/AUTH-FE-001
```

---

## Environment Variables

Required in `.env`:

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key

# Agent Configuration
WORKTREE_BASE=~/worktrees
MAIN_REPO=/path/to/main/repo

# Slack Notifications (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
SLACK_CHANNEL=#dev-notifications
```

---

## Validation Checklist

Before starting multi-agent execution:

```bash
# 1. CLAUDE.md exists with forbidden operations
grep -c "NEVER\|FORBIDDEN" CLAUDE.md  # Should be 100+

# 2. Database tables exist
psql $DATABASE_URL -c "SELECT COUNT(*) FROM stories"

# 3. Worktrees are set up
./scripts/maf-worktree.sh list | wc -l  # Should be 29+

# 4. PM Validator passes
./scripts/pm-validator.sh  # Should show GO

# 5. Signal helpers compile
npx tsc --noEmit src/lib/maf/signal-helpers.ts
```

---

## Quick Reference Cards

### Signal Types

| Signal | From | To | When |
|--------|------|----|------|
| story_assigned | PM | Dev | Story assigned |
| ready_for_qa | Dev | QA | Gate 3 complete |
| qa_approved | QA | PM | Gate 4 pass |
| qa_rejected | QA | Dev | Gate 4 fail |
| ready_for_merge | PM | CTO | Gate 5 complete |
| merge_complete | CTO | All | Gate 7 complete |
| emergency_stop | CTO | All | Emergency halt |

### Gate Ownership

| Gate | Owner | Output |
|------|-------|--------|
| 0 | CTO | Architecture approval |
| 1 | Dev | START.md, ROLLBACK-PLAN.md |
| 2 | Dev | Code implementation (TDD) |
| 3 | Dev | Tests passing, 80%+ coverage |
| 4 | QA | Independent validation |
| 5 | PM | Code review, docs check |
| 6 | Auto | CI/CD pipeline |
| 7 | CTO | Merge to main |

### Emergency Levels

| Level | Action | Recovery |
|-------|--------|----------|
| E1 | Self-correct | Agent fixes and continues |
| E2 | Retry | Rollback and retry different approach |
| E3 | Escalate | Signal PM for help |
| E4 | Agent stop | Halt this agent |
| E5 | Wave stop | Halt all agents |

---

## Troubleshooting

### "Worktree already exists"

```bash
./scripts/maf-worktree.sh cleanup fe-auth
./scripts/maf-worktree.sh create fe-auth
```

### "Signal not received"

```sql
-- Check pending signals
SELECT * FROM signals 
WHERE to_agent = 'qa-auth' 
AND status = 'pending';
```

### "Agent stuck"

```sql
-- Check stuck agents
SELECT * FROM stuck_agents_summary;

-- Trigger rollback
SELECT execute_rollback(checkpoint_id, 'pm', 'Agent stuck');
```

### "Database connection failed"

```bash
# Verify env vars
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY

# Test connection
psql $DATABASE_URL -c "SELECT 1"
```

---

## Summary

The MAF is now fully configured with:

| Component | Files | Purpose |
|-----------|-------|---------|
| Safety | CLAUDE.md | 108 forbidden ops, emergency levels |
| Domains | DOMAINS.md | 12 domain boundaries |
| Agents | AGENTS.md | 29 agent definitions |
| Schema | ai-story-schema-v4.json | Story validation |
| Templates | START.md, ROLLBACK-PLAN.md | Gate 1 outputs |
| Database | maf-complete-migration.sql | 9 tables, 4 functions |
| Signals | signal-helpers.ts | Agent communication |
| Tools | maf-worktree.sh | Infrastructure automation |
| Validation | pm-validator R+S | 30 new checks |

**Total:** 17 deliverables, ~4,500 lines

---

**Ready for Multi-Agent Execution!** 🚀
