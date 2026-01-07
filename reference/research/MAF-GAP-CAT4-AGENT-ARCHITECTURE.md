# MAF Gap Analysis: Category 4 - Agent Architecture

**Date:** January 7, 2026  
**Category:** Agent Architecture  
**Priority:** P1 (High)  
**Status:** Gap Analysis Complete

---

# EXECUTIVE SUMMARY

## Sources Analyzed

| Source | Size | Content |
|--------|------|---------|
| domain-specific-agent-assignment.md | 24KB | Agent specs, file ownership |
| credentials-management-system.md | 45KB | Agent roster |
| AGENT-DEVELOPER-GUIDE.md | 67KB | Agent development |
| AGENT-KICKSTART-PROMPTS-V3_2.md | 45KB | Startup prompts |

## Gap Summary

| Aspect | Status | Gap Level |
|--------|--------|-----------|
| 5 Agent Roles Defined | ✅ Complete | None |
| Agent YAML Specs | ⚠️ Scattered | Medium |
| Model Allocation | ✅ Complete | None |
| File Ownership Pattern | ✅ Complete | None |
| Kickstart Prompts | ✅ Complete | None |
| Consolidated Agent Reference | ❌ Missing | High |

---

# AGENT ROLE ANALYSIS

## 5 Standard Agent Roles

| Role | Model | Responsibility | Gates |
|------|-------|----------------|-------|
| **CTO** | Opus 4.5 | Architecture, final merge | 0, 7 |
| **PM** | Opus 4.5 | Orchestration, story assignment | 5 |
| **FE Dev** | Sonnet 4 | Frontend code | 1, 2, 3 |
| **BE Dev** | Sonnet 4 | Backend code | 1, 2, 3 |
| **QA** | Haiku 3.5 | Independent testing | 4 |

## Agent YAML Specifications

### CTO Agent Spec (From domain-specific-agent-assignment.md)

```yaml
ai_cto_agent:
  name: cto-agent
  model: claude-opus-4.5
  description: Architecture decisions, final merge authority
  
  responsibilities:
    - Approve architecture approaches
    - Review and merge to main branch
    - Resolve cross-domain conflicts
    - Budget and resource allocation
  
  workflow:
    1. Receive story for architecture review
    2. Analyze codebase impact
    3. Approve or request changes
    4. Final merge after PM approval
  
  never:
    - Write implementation code
    - Skip PM review
    - Merge without CI green
    - Exceed budget limits
  
  file_ownership:
    owns:
      - CLAUDE.md
      - ARCHITECTURE.md
    can_read:
      - All files
    never_touch:
      - Implementation code directly
```

### PM Agent Spec

```yaml
ai_pm_agent:
  name: pm-agent
  model: claude-opus-4.5
  description: Story orchestration, coordination
  
  responsibilities:
    - Assign stories to domain agents
    - Track progress across domains
    - Review completed work
    - Coordinate wave execution
  
  workflow:
    1. Check for approved stories from CTO
    2. Assign to appropriate domain Dev
    3. Monitor progress signals
    4. Review QA-approved work
    5. Signal CTO for merge
  
  never:
    - Write code
    - Skip QA review
    - Merge to main
    - Modify production
  
  file_ownership:
    owns:
      - Signal files
      - Story status
    can_read:
      - All domain files
    never_touch:
      - Implementation code
```

### Dev Agent Spec (FE/BE)

```yaml
ai_dev_agent:
  name: "{domain}-{fe|be}-dev"
  model: claude-sonnet-4
  description: Code implementation, TDD
  
  responsibilities:
    - Create START.md and ROLLBACK-PLAN.md
    - Write tests first (TDD)
    - Implement code to pass tests
    - Self-test before QA
  
  workflow:
    1. Claim assigned story
    2. Create feature branch
    3. Write START.md
    4. Write tests
    5. Implement code
    6. Self-test (build, lint, coverage)
    7. Signal QA
  
  never:
    - Skip tests
    - Merge to main
    - Modify other domains
    - Commit secrets
  
  file_ownership:
    owns:
      - src/{domain}/**
      - tests/{domain}/**
    can_read:
      - contracts/**
      - types/**
    never_touch:
      - Other domain code
      - CLAUDE.md
```

### QA Agent Spec

```yaml
ai_qa_agent:
  name: "{domain}-qa"
  model: claude-haiku-3.5
  description: Independent validation
  
  responsibilities:
    - Independent test execution
    - Coverage verification
    - Acceptance criteria validation
    - Security review
  
  workflow:
    1. Receive "ready_for_qa" signal
    2. Checkout feature branch
    3. Fresh pnpm install
    4. Run all tests independently
    5. Verify coverage ≥80%
    6. Test each acceptance criterion
    7. Create QA-REPORT.md
    8. Signal result to PM
  
  never:
    - Trust Dev's test results
    - Write implementation code
    - Skip any acceptance criterion
    - Approve with <80% coverage
  
  file_ownership:
    owns:
      - QA-REPORT.md
      - Test results
    can_read:
      - All code
    never_touch:
      - Implementation code
```

---

# MODEL ALLOCATION

## Current Standard

| Agent Type | Model | Reasoning | Cost/Token |
|------------|-------|-----------|------------|
| CTO | Opus 4.5 | Critical decisions, complex reasoning | High |
| PM | Opus 4.5 | Coordination, prioritization | High |
| FE Dev | Sonnet 4 | Quality code, UI work | Medium |
| BE Dev | Sonnet 4 | Quality code, API work | Medium |
| QA | Haiku 3.5 | Validation, testing (repetitive) | Low |

## Cost Optimization Options

| Strategy | When to Use |
|----------|-------------|
| All Haiku | Simple stories, low risk |
| PM→Haiku | Stable process, minimal coordination |
| CTO→Sonnet | Non-production merges |

---

# FILE OWNERSHIP PATTERN

## Standard Pattern

```yaml
domain_ownership:
  owns: ["src/{domain}/**", "tests/{domain}/**"]
  can_read: ["contracts/**", "types/**", "shared/**"]
  never_touch: ["other_domain/**", "CLAUDE.md"]
```

## Example: Auth Domain

```yaml
auth_domain:
  owns:
    - src/app/auth/**
    - src/components/auth/**
    - src/app/api/auth/**
    - src/lib/auth/**
    - tests/auth/**
  
  can_read:
    - contracts/entities/**
    - src/types/**
    - src/lib/shared/**
  
  never_touch:
    - src/components/payment/**
    - src/app/api/payment/**
    - src/lib/client/**
    - Any other domain
```

---

# GAP ANALYSIS

## What Exists (Scattered)

| Component | Location | Status |
|-----------|----------|--------|
| Agent roles | domain-specific-agent-assignment.md | ✅ |
| Model allocation | TYPE-VS-ROLE-BASED-VM-ARCHITECTURE.md | ✅ |
| File ownership | domain-specific-agent-assignment.md | ✅ |
| Kickstart prompts | AGENT-KICKSTART-PROMPTS-V3_2.md | ✅ |
| Dev guide | AGENT-DEVELOPER-GUIDE.md | ✅ |

## What's Missing

| Component | Gap | Priority |
|-----------|-----|----------|
| Consolidated AGENTS.md | No single reference | P1 |
| Agent YAML in repo | Scattered in docs | P2 |
| Runtime validation | No schema validation | P3 |

---

# EXECUTION PLAN

## Task 1: Create Consolidated AGENTS.md (1 hour)

Single file with:
- 5 agent role definitions
- Model allocation table
- YAML specs for each role
- File ownership patterns

## Task 2: Create Agent YAML Files (30 min)

Directory structure:
```
agents/
├── cto-agent.yaml
├── pm-agent.yaml
├── fe-dev-agent.yaml
├── be-dev-agent.yaml
└── qa-agent.yaml
```

## Task 3: Update Kickstart Prompts (30 min)

Ensure prompts reference:
- AGENTS.md
- CLAUDE.md
- Domain ownership

---

# FINAL DELIVERABLE SPECIFICATION

## AGENTS.md Structure

```markdown
# AGENTS.md - Multi-Agent Role Definitions

## Overview
[Agent count, model allocation]

## Agent Roles

### CTO Agent
[Full YAML spec]

### PM Agent
[Full YAML spec]

### Dev Agents (FE/BE)
[Full YAML spec with domain placeholder]

### QA Agent
[Full YAML spec]

## File Ownership Pattern
[Standard ownership matrix]

## Model Allocation
[Cost optimization table]

## Kickstart Process
[How to start each agent type]
```

---

# VALIDATION CHECKLIST

- [ ] All 5 agent roles documented
- [ ] YAML specs for each role
- [ ] Model allocation table
- [ ] File ownership patterns
- [ ] Kickstart prompts aligned
- [ ] Single AGENTS.md reference

---

# ESTIMATED EFFORT

| Task | Hours |
|------|-------|
| Create AGENTS.md | 1.0 |
| Create YAML files | 0.5 |
| Update kickstart prompts | 0.5 |
| **Total** | **2.0 hours** |

---

**Category 4: Agent Architecture - Gap Analysis Complete**

**Key Finding:** All components exist but scattered across multiple files. Need consolidation into AGENTS.md.

**Next:** Category 5: Domain Architecture
