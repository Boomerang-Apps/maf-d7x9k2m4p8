# AirView Agent Definitions

> **Version:** 1.0  
> **Last Updated:** January 7, 2026  
> **Purpose:** Define agent types, responsibilities, configurations, and communication patterns

---

## Overview

The Multi-Agent Framework (MAF) uses **specialized AI agents** to handle different aspects of software development. Each agent has defined responsibilities, owned domains, model assignments, and communication protocols.

### Agent Summary

| Category | Count | Agents |
|----------|-------|--------|
| Management | 2 | CTO, PM |
| Frontend Dev | 10 | fe-auth, fe-client, fe-pilot, etc. |
| Backend Dev | 10 | be-auth, be-client, be-pilot, etc. |
| Quality Assurance | 5 | qa-core, qa-auth, qa-transactions, qa-comms, qa-integration |
| Infrastructure | 2 | devops, security |
| **TOTAL** | **29** | |

---

## Agent Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          AGENT HIERARCHY                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                              ┌─────────┐                                    │
│                              │   CTO   │ ◄── Master Authority               │
│                              │ (Opus)  │     Gate 0 + Gate 7                │
│                              └────┬────┘                                    │
│                                   │                                         │
│                              ┌────▼────┐                                    │
│                              │   PM    │ ◄── Orchestration                  │
│                              │ (Opus)  │     Gate 5                         │
│                              └────┬────┘                                    │
│                                   │                                         │
│         ┌─────────────────────────┼─────────────────────────┐               │
│         │                         │                         │               │
│    ┌────▼────┐              ┌────▼────┐              ┌────▼────┐           │
│    │ Dev FE  │              │ Dev BE  │              │   QA    │           │
│    │(Sonnet) │              │(Sonnet) │              │(Haiku)  │           │
│    │ x10     │              │ x10     │              │ x5      │           │
│    └─────────┘              └─────────┘              └─────────┘           │
│                                                                             │
│    Gate 1,2,3               Gate 1,2,3               Gate 4                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Agent Type Definitions

### 1. CTO Agent

**Identity:**
| Field | Value |
|-------|-------|
| Agent Code | `cto` |
| Agent Type | Management |
| Model | claude-opus-4-5-20251101 |
| Domain | All (global authority) |
| Location | Main repository (not worktree) |

**Responsibilities:**
- Architecture decisions and approval (Gate 0)
- Final merge to main branch (Gate 7)
- Override authority for all agent decisions
- Emergency stop authorization
- Cross-domain conflict resolution

**Gate Ownership:**
| Gate | Role |
|------|------|
| Gate 0 | **OWNER** - Research & architecture approval |
| Gate 7 | **OWNER** - Merge to main (ONLY CTO can merge) |

**Authority:**
- ✅ Can override any agent decision with documented reason
- ✅ Can halt any wave or agent
- ✅ Can reassign stories across domains
- ✅ Only agent authorized to merge to main
- ❌ Cannot skip Gate 4 (QA) or Gate 5 (PM) approvals

**Communication:**
```sql
-- Signals CTO sends
INSERT INTO signals (type, from_agent, to_agent, data) VALUES
  ('GATE_0_APPROVED', 'cto', 'pm', '{"story_id": "AUTH-FE-001"}'),
  ('MERGE_COMPLETE', 'cto', 'all', '{"story_id": "AUTH-FE-001", "commit": "abc123"}'),
  ('EMERGENCY_STOP', 'cto', 'all', '{"level": "E3", "reason": "..."}');
```

---

### 2. PM Agent

**Identity:**
| Field | Value |
|-------|-------|
| Agent Code | `pm` |
| Agent Type | Management |
| Model | claude-opus-4-5-20251101 |
| Domain | All (coordination) |
| Location | Main repository (not worktree) |

**Responsibilities:**
- Story assignment and tracking
- Wave orchestration
- Code review and documentation check (Gate 5)
- Conflict coordination between agents
- Progress reporting to CTO

**Gate Ownership:**
| Gate | Role |
|------|------|
| Gate 5 | **OWNER** - PM review and standards check |

**Authority:**
- ✅ Can assign/reassign stories to dev agents
- ✅ Can pause stories for clarification
- ✅ Can reject at Gate 5 with specific feedback
- ❌ Cannot merge to main (CTO only)
- ❌ Cannot override CTO decisions

**Communication:**
```sql
-- Signals PM sends
INSERT INTO signals (type, from_agent, to_agent, data) VALUES
  ('STORY_ASSIGNED', 'pm', 'fe-auth', '{"story_id": "AUTH-FE-001"}'),
  ('READY_FOR_MERGE', 'pm', 'cto', '{"story_id": "AUTH-FE-001"}'),
  ('PM_REJECTED', 'pm', 'fe-auth', '{"story_id": "AUTH-FE-001", "reason": "..."}');
```

---

### 3. Frontend Dev Agents (10 agents)

**Template:**
| Field | Value |
|-------|-------|
| Agent Code | `fe-{domain}` |
| Agent Type | Frontend Development |
| Model | claude-sonnet-4-20250514 |
| Domain | Specific domain |
| Location | Git worktree |

**Agent List:**

| Agent Code | Domain | QA Partner | Owned Paths |
|------------|--------|------------|-------------|
| `fe-auth` | AUTH | qa-auth | src/app/auth/**, src/components/auth/** |
| `fe-client` | CLIENT | qa-core | src/app/client/**, src/components/client/** |
| `fe-pilot` | PILOT | qa-core | src/app/pilot/**, src/components/pilot/** |
| `fe-project` | PROJECT | qa-core | src/app/projects/**, src/components/project/** |
| `fe-proposal` | PROPOSAL | qa-core | src/app/proposals/**, src/components/proposal/** |
| `fe-payment` | PAYMENT | qa-transactions | src/app/payments/**, src/components/payment/** |
| `fe-deliverables` | DELIVERABLES | qa-core | src/app/deliverables/**, src/components/deliverables/** |
| `fe-messaging` | MESSAGING | qa-comms | src/app/messages/**, src/components/messaging/** |
| `fe-admin` | ADMIN | qa-core | src/app/admin/**, src/components/admin/** |
| `fe-layout` | LAYOUT | qa-core | src/components/ui/**, src/components/layout/** |

**Responsibilities:**
- Create and modify frontend components
- Implement UI according to specifications
- Write unit and integration tests
- Ensure 80%+ test coverage
- Follow TDD approach

**Gate Ownership:**
| Gate | Role |
|------|------|
| Gate 1 | **OWNER** - Planning (START.md, ROLLBACK-PLAN.md) |
| Gate 2 | **OWNER** - Building (TDD implementation) |
| Gate 3 | **OWNER** - Self-test (coverage ≥80%) |

**Communication:**
```sql
-- Signal to QA when ready
INSERT INTO signals (type, from_agent, to_agent, story_id, data) VALUES
  ('READY_FOR_QA', 'fe-auth', 'qa-auth', 'AUTH-FE-001', '{
    "branch": "feature/AUTH-FE-001-login-form",
    "coverage": 85,
    "tests_passed": 24,
    "commits": 5
  }');
```

---

### 4. Backend Dev Agents (10 agents)

**Template:**
| Field | Value |
|-------|-------|
| Agent Code | `be-{domain}` |
| Agent Type | Backend Development |
| Model | claude-sonnet-4-20250514 |
| Domain | Specific domain |
| Location | Git worktree |

**Agent List:**

| Agent Code | Domain | QA Partner | Owned Paths |
|------------|--------|------------|-------------|
| `be-auth` | AUTH | qa-auth | src/app/api/auth/**, src/lib/auth/** |
| `be-client` | CLIENT | qa-core | src/app/api/clients/**, src/lib/client/** |
| `be-pilot` | PILOT | qa-core | src/app/api/pilots/**, src/lib/pilot/** |
| `be-project` | PROJECT | qa-core | src/app/api/projects/**, src/lib/project/** |
| `be-proposal` | PROPOSAL | qa-core | src/app/api/proposals/**, src/lib/proposal/** |
| `be-payment` | PAYMENT | qa-transactions | src/app/api/payments/**, src/lib/stripe/** |
| `be-deliverables` | DELIVERABLES | qa-core | src/app/api/deliverables/**, src/lib/storage/** |
| `be-messaging` | MESSAGING | qa-comms | src/app/api/messages/**, src/lib/realtime/** |
| `be-admin` | ADMIN | qa-core | src/app/api/admin/**, src/lib/admin/** |
| `be-core` | CORE | qa-integration | src/lib/supabase/**, src/lib/utils/** |

**Responsibilities:**
- Create and modify API endpoints
- Implement database schemas and migrations
- Write API tests
- Ensure 80%+ test coverage
- Follow TDD approach

**Gate Ownership:**
| Gate | Role |
|------|------|
| Gate 1 | **OWNER** - Planning (START.md, ROLLBACK-PLAN.md) |
| Gate 2 | **OWNER** - Building (TDD implementation) |
| Gate 3 | **OWNER** - Self-test (coverage ≥80%) |

**Communication:**
```sql
-- Signal to QA when ready
INSERT INTO signals (type, from_agent, to_agent, story_id, data) VALUES
  ('READY_FOR_QA', 'be-auth', 'qa-auth', 'AUTH-BE-001', '{
    "branch": "feature/AUTH-BE-001-login-api",
    "coverage": 88,
    "tests_passed": 18,
    "api_endpoints": ["/api/auth/login", "/api/auth/logout"]
  }');
```

---

### 5. QA Agents (5 agents)

**Template:**
| Field | Value |
|-------|-------|
| Agent Code | `qa-{specialty}` |
| Agent Type | Quality Assurance |
| Model | claude-haiku-4-5-20251001 |
| Domain | Multiple (by specialty) |
| Location | Git worktree |

**Agent List:**

| Agent Code | Specialty | Covers Domains | Responsibilities |
|------------|-----------|----------------|------------------|
| `qa-core` | Core validation | CLIENT, PILOT, PROJECT, PROPOSAL, DELIVERABLES, ADMIN, LAYOUT | General feature testing |
| `qa-auth` | Authentication | AUTH | Security-focused testing, auth flows |
| `qa-transactions` | Financial | PAYMENT | Payment flows, Stripe integration |
| `qa-comms` | Communication | MESSAGING, NOTIFICATIONS | Real-time features, messaging |
| `qa-integration` | Integration | CORE, cross-domain | E2E tests, integration scenarios |

**Responsibilities:**
- Independent validation (NOT self-review)
- Run full test suite
- Verify acceptance criteria
- Check code quality
- Security review (for qa-auth)

**Gate Ownership:**
| Gate | Role |
|------|------|
| Gate 4 | **OWNER** - QA validation and approval |

**QA Report Format:**
```sql
INSERT INTO qa_reports (story_id, qa_agent, verdict, test_coverage, tests_passed, tests_total, notes) VALUES
  ('story-uuid', 'qa-auth', 'PASS', 87.5, 24, 24, 'All acceptance criteria validated');
```

**Communication:**
```sql
-- Signal approval to PM
INSERT INTO signals (type, from_agent, to_agent, story_id, data) VALUES
  ('QA_APPROVED', 'qa-auth', 'pm', 'AUTH-FE-001', '{
    "coverage": 87.5,
    "tests_passed": 24,
    "tests_total": 24,
    "security_check": "passed"
  }');

-- Signal rejection to Dev
INSERT INTO signals (type, from_agent, to_agent, story_id, data) VALUES
  ('QA_REJECTED', 'qa-auth', 'fe-auth', 'AUTH-FE-001', '{
    "failed_criteria": ["AC-2", "AC-5"],
    "bugs": [{"id": "BUG-001", "description": "..."}],
    "required_fixes": ["Fix validation on empty email"]
  }');
```

---

### 6. DevOps Agent

**Identity:**
| Field | Value |
|-------|-------|
| Agent Code | `devops` |
| Agent Type | Infrastructure |
| Model | claude-sonnet-4-20250514 |
| Domain | Infrastructure |
| Location | Main repository |

**Responsibilities:**
- CI/CD pipeline monitoring (Gate 6)
- Infrastructure configuration
- Deployment automation
- Environment management

**Gate Ownership:**
| Gate | Role |
|------|------|
| Gate 6 | **MONITOR** - CI/CD pipeline oversight |

---

### 7. Security Agent

**Identity:**
| Field | Value |
|-------|-------|
| Agent Code | `security` |
| Agent Type | Security |
| Model | claude-sonnet-4-20250514 |
| Domain | All (security review) |
| Location | Main repository |

**Responsibilities:**
- Security vulnerability scanning
- Code security review
- Dependency audit
- Report security issues

**Gate Ownership:**
| Gate | Role |
|------|------|
| Gate 4 | **SUPPORT** - Security review assistance |

---

## Agent Pairing

### Dev-QA Pairs

Each dev agent is paired with a QA agent for independent validation:

| Dev Agent | QA Partner | Rationale |
|-----------|------------|-----------|
| fe-auth, be-auth | qa-auth | Security-critical domain |
| fe-payment, be-payment | qa-transactions | Financial transactions |
| fe-messaging, be-messaging | qa-comms | Real-time communication |
| fe-core, be-core | qa-integration | Shared infrastructure |
| All others | qa-core | General validation |

### Pairing Rules

1. **1:1 Pairing** - Each dev story gets independent QA validation
2. **No Self-Review** - Dev agent cannot QA their own code
3. **Domain Expertise** - QA agents specialize by domain type
4. **Escalation** - Complex issues escalate to qa-integration

---

## Model Assignments

### Cost Optimization Strategy

| Agent Type | Model | Reason | Cost Impact |
|------------|-------|--------|-------------|
| CTO | Opus 4.5 | Complex architecture decisions | Higher |
| PM | Opus 4.5 | Orchestration and coordination | Higher |
| Dev (FE/BE) | Sonnet 4 | Code generation, balance of speed/quality | Medium |
| QA | Haiku 4.5 | Validation tasks, cost savings | Lower (3x savings) |
| DevOps | Sonnet 4 | Infrastructure tasks | Medium |
| Security | Sonnet 4 | Security analysis | Medium |

### Model Configuration

```bash
# Environment variables for model assignment
ANTHROPIC_MODEL_CTO=claude-opus-4-5-20251101
ANTHROPIC_MODEL_PM=claude-opus-4-5-20251101
ANTHROPIC_MODEL_DEV=claude-sonnet-4-20250514
ANTHROPIC_MODEL_QA=claude-haiku-4-5-20251001
```

---

## Agent Communication Protocol

### Signal Types

| Signal Type | From | To | Purpose |
|-------------|------|-----|---------|
| `GATE_0_APPROVED` | CTO | PM | Architecture approved |
| `STORY_ASSIGNED` | PM | Dev | Story assignment |
| `READY_FOR_QA` | Dev | QA | Development complete |
| `QA_APPROVED` | QA | PM | Validation passed |
| `QA_REJECTED` | QA | Dev | Validation failed |
| `READY_FOR_MERGE` | PM | CTO | Ready for main |
| `MERGE_COMPLETE` | CTO | All | Story merged |
| `EMERGENCY_STOP` | CTO | All | Halt operations |

### Signal Flow

```
Dev Agent (Gates 0-3)
       │
       ├── READY_FOR_QA ──────────► QA Agent (Gate 4)
       │                                  │
       │   ◄── QA_REJECTED ───────────────┤
       │                                  │
       │                                  ├── QA_APPROVED ──────► PM Agent (Gate 5)
       │                                  │                              │
       │                                  │   ◄── PM_REJECTED ───────────┤
       │                                  │                              │
       │                                  │                              ├── READY_FOR_MERGE ──► CTO (Gate 7)
       │                                  │                              │                              │
       │                                  │                              │                              ├── MERGE_COMPLETE ──► All
       │                                  │                              │                              │
       │                                  │                              │   ◄── MERGE_REJECTED ────────┤
```

---

## Worktree Configuration

Each dev and QA agent operates in an isolated Git worktree:

```bash
# Worktree structure
/worktrees/
├── fe-auth/           # Frontend auth agent
├── fe-client/         # Frontend client agent
├── be-auth/           # Backend auth agent
├── be-client/         # Backend client agent
├── qa-core/           # QA core agent
├── qa-auth/           # QA auth agent
└── ...
```

### Worktree Creation

```bash
# Create worktree for agent
git worktree add /worktrees/fe-auth -b feature/AUTH-FE-001-login-form main

# Agent works in isolated worktree
cd /worktrees/fe-auth
claude -p "Read CLAUDE.md and begin Gate 1"
```

---

## Agent Session Management

### Database Schema

```sql
CREATE TABLE agent_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id VARCHAR(100) UNIQUE NOT NULL,
    agent_type VARCHAR(50) NOT NULL,  -- cto, pm, dev, qa
    domain VARCHAR(50),                -- NULL for CTO/PM
    model VARCHAR(100),
    status VARCHAR(50) DEFAULT 'starting',
    -- starting, active, idle, working, blocked, terminated
    current_story_id UUID,
    current_gate INTEGER,
    last_heartbeat TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_tokens_used INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Status Values

| Status | Description |
|--------|-------------|
| `starting` | Agent initializing |
| `active` | Agent running, available for work |
| `idle` | Agent waiting for assignment |
| `working` | Agent actively on a story |
| `blocked` | Agent waiting for dependency |
| `terminated` | Agent stopped |

---

## Adding a New Agent

To add a new agent to the system:

### 1. Define in Database

```sql
INSERT INTO agents (agent_code, agent_type, domain, model, owned_paths, is_active) VALUES
  ('fe-newdomain', 'frontend', 'newdomain', 'claude-sonnet-4-20250514', 
   ARRAY['src/app/newdomain/**', 'src/components/newdomain/**'], true);
```

### 2. Create QA Pairing

```sql
INSERT INTO agent_pairs (dev_agent, qa_agent, domain) VALUES
  ('fe-newdomain', 'qa-core', 'newdomain');
```

### 3. Create Worktree

```bash
git worktree add /worktrees/fe-newdomain main
```

### 4. Create CLAUDE.md

```bash
cp templates/CLAUDE.md.template /worktrees/fe-newdomain/CLAUDE.md
# Edit with agent-specific configuration
```

### 5. Update DOMAINS.md

Add the new domain to DOMAINS.md with boundaries and rules.

---

## Quick Reference

### Agent Codes by Domain

| Domain | Frontend | Backend | QA |
|--------|----------|---------|-----|
| AUTH | fe-auth | be-auth | qa-auth |
| CLIENT | fe-client | be-client | qa-core |
| PILOT | fe-pilot | be-pilot | qa-core |
| PROJECT | fe-project | be-project | qa-core |
| PROPOSAL | fe-proposal | be-proposal | qa-core |
| PAYMENT | fe-payment | be-payment | qa-transactions |
| DELIVERABLES | fe-deliverables | be-deliverables | qa-core |
| MESSAGING | fe-messaging | be-messaging | qa-comms |
| ADMIN | fe-admin | be-admin | qa-core |
| LAYOUT | fe-layout | - | qa-core |
| CORE | - | be-core | qa-integration |

### Gate Ownership Summary

| Agent Type | Gate 0 | Gate 1 | Gate 2 | Gate 3 | Gate 4 | Gate 5 | Gate 6 | Gate 7 |
|------------|--------|--------|--------|--------|--------|--------|--------|--------|
| **CTO** | ✅ OWNER | - | - | - | - | - | - | ✅ OWNER |
| **PM** | - | - | - | - | - | ✅ OWNER | - | - |
| **Dev** | Support | ✅ OWNER | ✅ OWNER | ✅ OWNER | - | - | - | - |
| **QA** | - | - | - | - | ✅ OWNER | - | - | - |
| **DevOps** | - | - | - | - | - | - | Monitor | - |
| **Security** | - | - | - | - | Support | - | - | - |

---

**End of Document**
