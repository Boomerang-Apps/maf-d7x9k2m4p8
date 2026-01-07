# MAF Framework: Complete Category Breakdown (Updated)

**Date:** January 7, 2026  
**Purpose:** Identify ALL MAF categories from documentation for gap analysis  
**Method:** Deep analysis of 140+ project files

---

# IDENTIFIED MAF CATEGORIES (9 Total)

| # | Category | Key Files | Purpose |
|---|----------|-----------|---------|
| 1 | **AI Stories** | ai-story-schema, AI-STORY-*.md, linter | Story format, validation, templates |
| 2 | **Safety Protocol** | CLAUDE.md, FMEA.md, COMPLETE-SAFETY-REFERENCE.md | 94 forbidden ops, kill switch, guardrails |
| 3 | **8-Gate System** | GATE-*.md, workflow-3_0-protocol.md | Quality gates, entry/exit criteria |
| 4 | **Agent Architecture** | domain-specific-agent-assignment.md, AGENT-KICKSTART-PROMPTS.md | 5 agent roles, prompts, model allocation |
| 5 | **Domain Architecture** | ISSUE-03-DOMAINS-MD-MISSING.md, TYPE-VS-ROLE-BASED-VM-ARCHITECTURE.md | 12 domains, ownership, boundaries, hierarchy |
| 6 | **Multi-Agent Orchestration** | MULTI-AGENT-ORCHESTRATION-COMPLETE-SETUP.md, async-multi-agent-coordination.md | Database schema, signals, waves, coordination |
| 7 | **Tools & Validation** | pm-validator-v5.7.sh, merge-watcher.sh, story-linter.ts | Automation, validation, monitoring |
| 8 | **Infrastructure** | DOCKER-MULTI-AGENT-IMPLEMENTATION-GUIDE.md, MULTI-AGENT-VM-SETUP-GUIDE.md | VMs, Docker, worktrees |
| 9 | **Operations** | DEPLOYMENT-RUNBOOK.md, INCIDENT-RESPONSE-PLAYBOOK.md | Production operations |

---

# CATEGORY 5: DOMAIN ARCHITECTURE (NEW - DETAILED)

## Documentation Found

| File | Size | Content |
|------|------|---------|
| ISSUE-03-DOMAINS-MD-MISSING.md | 24KB | **Complete domain spec** |
| TYPE-VS-ROLE-BASED-VM-ARCHITECTURE.md | 29KB | VM organization decision |
| domain-specific-agent-assignment.md | 24KB | Agent domain boundaries |
| MULTI-AGENT-ORCHESTRATION-COMPLETE-SETUP.md | 40KB+ | Full orchestration schema |

## Domain Hierarchy (12 Domains)

```
LEVEL 0: FOUNDATIONAL (No Dependencies)
├── AUTH       - User authentication & authorization
├── LAYOUT     - UI framework & design system
└── CORE       - Shared infrastructure

LEVEL 1: ENTITY (Depend on Foundational)
├── CLIENT     - Customer management
└── PILOT      - Drone pilot management

LEVEL 2: BUSINESS (Depend on Entity)
├── PROJECT       - Job/project lifecycle
├── PROPOSAL      - Quotes & proposals
├── PAYMENT       - Invoicing & payments
└── DELIVERABLES  - File uploads & reviews

LEVEL 3: SUPPORT (Cross-cutting)
├── MESSAGING      - Real-time chat
├── ADMIN          - System administration
└── NOTIFICATIONS  - Alerts & notifications
```

## Key Architectural Decisions

### Type-Based vs Role-Based VMs

**Verdict: TYPE-BASED (Domain VMs) is SUPERIOR**

| Factor | Type-Based (Auth VM, Payment VM) | Role-Based (Frontend VM, Backend VM) |
|--------|----------------------------------|--------------------------------------|
| Parallel Execution | ✅ 10 domains = 10 parallel | ⚠️ 2-3 roles = bottleneck |
| Conflict Prevention | ✅ Zero cross-domain | ❌ FE/BE touch same files |
| Scaling | ✅ Add domains independently | ⚠️ All roles must scale |
| Context Switching | ✅ None | ❌ Constant FE↔BE |

### Domain VM Structure

```
Domain VM (e.g., Auth VM)
├── CTO Agent (Opus 4.5)     - Architecture decisions
├── PM Agent (Opus 4.5)      - Story orchestration
├── FE Dev Agent (Sonnet 4)  - Frontend code
├── BE Dev Agent (Sonnet 4)  - Backend code
└── QA Agent (Haiku 3.5)     - Independent testing
```

### File Ownership Pattern

```yaml
auth_domain:
  owns:
    - src/app/auth/**
    - src/components/auth/**
    - src/app/api/auth/**
    - src/lib/auth/**
  can_read:
    - contracts/**
    - src/types/**
  forbidden:
    - src/components/payment/**
    - src/app/api/payment/**
    - Other domain paths
```

### Cross-Domain Communication Rules

```
RULE 1: Never import components from other domains
RULE 2: Use contracts/entities/*.ts for shared types
RULE 3: Use API endpoints for cross-domain data
RULE 4: Shared files (schema) require CTO approval
```

---

# CATEGORY 6: MULTI-AGENT ORCHESTRATION (DETAILED)

## Documentation Found

| File | Size | Content |
|------|------|---------|
| MULTI-AGENT-ORCHESTRATION-COMPLETE-SETUP.md | 40KB+ | **Complete setup guide** |
| multi-agent-work-distribution.md | 31KB | Distribution patterns |
| agent-communication-patterns.md | 32KB | Communication types |
| async-multi-agent-coordination.md | 23KB | Async coordination |

## Database Schema (Core Tables)

```sql
-- WAVES - Project phases
CREATE TABLE waves (
    id UUID PRIMARY KEY,
    wave_code VARCHAR(50) UNIQUE,
    name VARCHAR(255),
    status VARCHAR(50), -- planning, active, completed
    priority INTEGER
);

-- STORIES - Work items
CREATE TABLE stories (
    id UUID PRIMARY KEY,
    wave_id UUID REFERENCES waves(id),
    story_code VARCHAR(50) UNIQUE,
    domain VARCHAR(50),      -- auth, client, pilot, etc.
    status VARCHAR(50),      -- backlog, ready, in_progress, qa_review, completed
    current_gate INTEGER,    -- 0-7
    assigned_agent VARCHAR(100),
    branch_name VARCHAR(255)
);

-- SIGNALS - Agent communication
CREATE TABLE signals (
    id UUID PRIMARY KEY,
    signal_type VARCHAR(100), -- story_assigned, ready_for_qa, qa_approved, etc.
    from_agent VARCHAR(100),
    to_agent VARCHAR(100),
    story_id UUID REFERENCES stories(id),
    status VARCHAR(50),       -- pending, acknowledged, processed
    payload JSONB
);

-- AGENT_SESSIONS - Active agents
CREATE TABLE agent_sessions (
    id UUID PRIMARY KEY,
    agent_id VARCHAR(100) UNIQUE,
    agent_type VARCHAR(50),   -- cto, pm, dev, qa
    domain VARCHAR(50),
    status VARCHAR(50),       -- active, idle, working, blocked
    current_story_id UUID,
    current_gate INTEGER
);
```

## Signal Flow

```
STORY LIFECYCLE:
═══════════════

1. CTO approves story      → status: "ready"
2. PM assigns to Dev       → signal: "story_assigned"
3. Dev claims & works      → status: "in_progress"
4. Dev completes G1-G3     → signal: "ready_for_qa"
5. QA validates            → signal: "qa_approved" OR "qa_rejected"
6. PM reviews              → signal: "ready_for_merge"
7. CTO merges              → status: "completed"
```

## Agent Kickstart Prompts

| Agent | Key Instructions |
|-------|------------------|
| **CTO** | Architecture approval, merge authority, Gate 0 + 7 |
| **PM** | Story assignment, orchestration, Gate 5 |
| **Dev** | TDD implementation, Gates 1-3, signal QA |
| **QA** | Independent validation, Gate 4, never trust Dev |

---

# UPDATED GAP ANALYSIS PLAN

## Phase 1: Category-by-Category Analysis (9 Categories)

| Order | Category | Priority | Key Questions |
|-------|----------|----------|---------------|
| 1 | AI Stories | P0 | Schema merge, validation |
| 2 | Safety Protocol | P0 | Is V10.7 complete? |
| 3 | 8-Gate System | P1 | START.md requirement? |
| 4 | Agent Architecture | P1 | 5 roles documented? |
| 5 | **Domain Architecture** | P1 | DOMAINS.md exists? Ownership map? |
| 6 | **Multi-Agent Orchestration** | P1 | DB schema, signals, waves |
| 7 | Tools & Validation | P2 | PM Validator checks |
| 8 | Infrastructure | P2 | VM setup |
| 9 | Operations | P3 | Deployment process |

## Key Questions for Domain Architecture

1. **Does DOMAINS.md exist?** - Currently an "issue" - needs creation
2. **Are all 12 domains documented?** - Hierarchy, boundaries
3. **Is file ownership defined per domain?** - owns/can_read/forbidden
4. **Are cross-domain rules explicit?** - Communication via contracts/APIs
5. **Is domain validation script created?** - Cross-import detection

## Key Questions for Multi-Agent Orchestration

1. **Is database schema deployed?** - waves, stories, signals, agent_sessions
2. **Are signal types documented?** - story_assigned, ready_for_qa, etc.
3. **Are agent kickstart prompts ready?** - Per-role templates
4. **Is monitoring dashboard available?** - Status queries, signal watcher
5. **Is wave-based execution documented?** - Dependencies, parallel groups

---

# DELIVERABLES PER CATEGORY

For each of the 9 categories:

| Deliverable | Purpose |
|-------------|---------|
| `MAF-GAP-[CATEGORY].md` | Gap analysis report |
| Key findings | What exists, what's missing |
| Execution plan | Tasks to consolidate |
| Final document spec | Target structure |

---

# CONFIRMED DOCUMENTATION SOURCES

## Category 5: Domain Architecture

| Document | Status | Content |
|----------|--------|---------|
| ISSUE-03-DOMAINS-MD-MISSING.md | ✅ Found | Full domain spec, hierarchy, rules |
| TYPE-VS-ROLE-BASED-VM-ARCHITECTURE.md | ✅ Found | VM architecture decision |
| domain-specific-agent-assignment.md | ✅ Found | Agent domain boundaries |
| DOMAINS.md | ❌ NOT CREATED | Needs creation from ISSUE-03 |

## Category 6: Multi-Agent Orchestration

| Document | Status | Content |
|----------|--------|---------|
| MULTI-AGENT-ORCHESTRATION-COMPLETE-SETUP.md | ✅ Found | Complete guide |
| multi-agent-work-distribution.md | ✅ Found | Distribution patterns |
| agent-communication-patterns.md | ✅ Found | Communication types |
| async-multi-agent-coordination.md | ✅ Found | Async coordination |
| multi-agent-vm-framework.md | ✅ Found | Framework overview |

---

# NEXT STEPS

**Confirm the 9 categories are correct, then proceed with gap analysis for each:**

1. **AI Stories** - Schema merge (already analyzed)
2. **Safety Protocol** - Verify V10.7 completeness
3. **8-Gate System** - Gate requirements
4. **Agent Architecture** - 5 roles, prompts
5. **Domain Architecture** - 12 domains, ownership
6. **Multi-Agent Orchestration** - DB schema, signals
7. **Tools & Validation** - PM Validator
8. **Infrastructure** - VMs, Docker
9. **Operations** - Deployment

**Ready to start gap analysis for each category?**
