# MAF Gap Analysis: Category 5 - Domain Architecture

**Date:** January 7, 2026  
**Category:** Domain Architecture  
**Priority:** P1 (High)  
**Status:** Gap Analysis Complete

---

# EXECUTIVE SUMMARY

## Sources Analyzed

| Source | Size | Content |
|--------|------|---------|
| ISSUE-03-DOMAINS-MD-MISSING.md | 24KB | Complete domain spec |
| TYPE-VS-ROLE-BASED-VM-ARCHITECTURE.md | 29KB | VM organization |
| domain-specific-agent-assignment.md | 24KB | Agent domain boundaries |

## Gap Summary

| Aspect | Status | Gap Level |
|--------|--------|-----------|
| Domain Definitions | ✅ In ISSUE-03 | Needs extraction |
| Domain Hierarchy | ✅ In ISSUE-03 | Needs extraction |
| File Ownership | ✅ Documented | Complete |
| Cross-Domain Rules | ✅ Documented | Complete |
| DOMAINS.md File | ❌ NOT CREATED | **CRITICAL** |
| Domain Validation Script | ❌ NOT CREATED | High |

**CRITICAL GAP:** DOMAINS.md does not exist as a file. The complete specification exists in ISSUE-03-DOMAINS-MD-MISSING.md but has never been implemented.

---

# DOMAIN HIERARCHY

## 12 Business Domains

### Level 0: Foundational (No Dependencies)

| Domain | Type | Description |
|--------|------|-------------|
| AUTH | Foundational | User authentication & authorization |
| LAYOUT | Foundational | UI framework & design system |
| CORE | Foundational | Shared infrastructure |

### Level 1: Entity (Depend on Foundational)

| Domain | Type | Dependencies |
|--------|------|--------------|
| CLIENT | Entity | AUTH |
| PILOT | Entity | AUTH |

### Level 2: Business (Depend on Entity)

| Domain | Type | Dependencies |
|--------|------|--------------|
| PROJECT | Business | CLIENT, PILOT, AUTH |
| PROPOSAL | Business | CLIENT, PILOT, PROJECT |
| PAYMENT | Business | CLIENT, PROJECT |
| DELIVERABLES | Business | PROJECT |

### Level 3: Support (Cross-Cutting)

| Domain | Type | Dependencies |
|--------|------|--------------|
| MESSAGING | Support | AUTH, CLIENT, PILOT |
| ADMIN | Support | AUTH (all domains readable) |
| NOTIFICATIONS | Support | Shared across all |

---

# DOMAIN OWNERSHIP MAP

## File Ownership Per Domain

### AUTH Domain

```yaml
auth:
  team_size: "2 dev + 1 QA"
  owns:
    - src/app/auth/**
    - src/components/auth/**
    - src/app/api/auth/**
    - src/lib/auth/**
    - tests/auth/**
  
  provides:
    - contracts/entities/user.ts
    - contracts/entities/session.ts
    - hooks/useAuth.ts
  
  consumes:
    - contracts/entities/base.ts
    - lib/supabase/client.ts
  
  never_imports:
    - src/components/payment/**
    - src/components/client/**
    - Any other domain components
```

### CLIENT Domain

```yaml
client:
  team_size: "2 dev + 1 QA"
  owns:
    - src/app/clients/**
    - src/components/client/**
    - src/app/api/clients/**
    - src/lib/client/**
    - tests/client/**
  
  provides:
    - contracts/entities/client.ts
    - hooks/useClient.ts
  
  consumes:
    - contracts/entities/user.ts (from AUTH)
    - lib/auth/** (read-only)
  
  never_imports:
    - src/components/pilot/**
    - src/components/payment/**
```

### Pattern for All Domains

```yaml
{domain}:
  team_size: "{count} dev + 1 QA"
  owns:
    - src/app/{domain}/**
    - src/components/{domain}/**
    - src/app/api/{domain}/**
    - src/lib/{domain}/**
    - tests/{domain}/**
  
  provides:
    - contracts/entities/{domain}.ts
    - hooks/use{Domain}.ts
  
  consumes:
    - [List of allowed imports]
  
  never_imports:
    - [Other domain components]
```

---

# CROSS-DOMAIN COMMUNICATION RULES

## The 4 Rules

```
RULE 1: Never Import Components Directly
❌ import { ClientCard } from '@/components/client/ClientCard'
✅ import { ClientEntity } from '@/contracts/entities/client'

RULE 2: Use Contracts for Shared Types
- All shared types go in contracts/entities/
- Each domain owns its entity type
- Other domains read-only

RULE 3: Use APIs for Cross-Domain Data
❌ Direct database access to other domain tables
✅ API call: fetch('/api/clients/{id}')

RULE 4: Shared Files Require CTO Approval
- prisma/schema.prisma
- contracts/shared.ts
- src/lib/shared/**
```

---

# DEPENDENCY GRAPH

```
                    FOUNDATIONAL (Level 0)
                    ┌─────┬─────┬─────┐
                    │AUTH │LAYOUT│CORE │
                    └──┬──┴──┬──┴──┬──┘
                       │     │     │
          ┌────────────┴─────┴─────┴────────────┐
          │                                      │
          ▼         ENTITY (Level 1)             ▼
     ┌────────┐                            ┌────────┐
     │ CLIENT │                            │ PILOT  │
     └────┬───┘                            └───┬────┘
          │                                    │
          │         BUSINESS (Level 2)         │
     ┌────┴───────────────────────────────────┴────┐
     │                                              │
     ▼          ▼          ▼           ▼           │
┌─────────┐┌─────────┐┌─────────┐┌─────────────┐  │
│ PROJECT ││PROPOSAL ││ PAYMENT ││DELIVERABLES │  │
└────┬────┘└─────────┘└─────────┘└─────────────┘  │
     │                                              │
     │           SUPPORT (Level 3)                 │
     ├──────────────────┬──────────────────────────┤
     ▼                  ▼                          ▼
┌─────────┐      ┌───────────┐            ┌───────────────┐
│MESSAGING│      │   ADMIN   │            │ NOTIFICATIONS │
└─────────┘      └───────────┘            └───────────────┘
```

---

# GAP ANALYSIS

## Critical Gap: DOMAINS.md Does Not Exist

The file `DOMAINS.md` that should be in the project root **has never been created**. The specification exists in ISSUE-03-DOMAINS-MD-MISSING.md but:

- [ ] DOMAINS.md not created
- [ ] Domain ownership not enforced
- [ ] No validation script
- [ ] Cross-domain violations possible

## What Exists

| Item | Location | Status |
|------|----------|--------|
| Domain definitions | ISSUE-03 | ✅ Complete spec |
| Domain hierarchy | ISSUE-03 | ✅ Complete |
| Ownership rules | ISSUE-03 | ✅ Complete |
| Validation script | ISSUE-03 (code only) | ❌ Not implemented |
| DOMAINS.md file | Expected in root | ❌ NOT CREATED |

---

# EXECUTION PLAN

## Task 1: Create DOMAINS.md (1 hour)

Extract from ISSUE-03 and create actual file:

```markdown
# AirView Domain Definitions

## Overview
AirView is organized into 12 domains...

## Domain Hierarchy
[Diagram and tables]

## Domain Specifications
### AUTH Domain
[Full ownership spec]

### CLIENT Domain
...

## Cross-Domain Rules
[4 rules]

## Dependency Graph
[ASCII diagram]
```

## Task 2: Create Domain Validation Script (1 hour)

Create `scripts/validate-domains.ts`:

```typescript
// From ISSUE-03 specification
interface DomainConfig {
  name: string;
  paths: string[];
  canImportFrom: string[];
}

const DOMAINS: Record<string, DomainConfig> = {
  auth: {
    name: 'Auth',
    paths: ['src/app/auth', 'src/components/auth', ...],
    canImportFrom: ['contracts', 'ui', 'layout', 'utils']
  },
  // ... all 12 domains
};

function checkCrossDomainViolations(): string[] {
  // Scan all files for import violations
}
```

## Task 3: Add Pre-Commit Hook (30 min)

```bash
#!/bin/bash
# .git/hooks/pre-commit

npx ts-node scripts/validate-domains.ts
if [ $? -ne 0 ]; then
  echo "Domain boundary violation detected!"
  exit 1
fi
```

## Task 4: Add PM Validator Section (30 min)

Add to pm-validator:

```bash
# Section S: Domain Validation
check_S1_domains_md_exists()
check_S2_no_cross_domain_imports()
check_S3_contracts_used_for_shared()
check_S4_apis_used_for_data()
```

---

# FINAL DELIVERABLE SPECIFICATION

## DOMAINS.md Structure

```markdown
# DOMAINS.md - AirView Domain Definitions

## Overview
- 12 business domains
- 4 hierarchy levels
- Strict isolation

## Domain Hierarchy
### Level 0: Foundational
### Level 1: Entity
### Level 2: Business
### Level 3: Support

## Domain Specifications
[12 domain YAML specs]

## Cross-Domain Rules
[4 numbered rules with examples]

## Dependency Graph
[ASCII diagram]

## Validation
- Run: `pnpm validate:domains`
- Pre-commit hook enabled
```

---

# VALIDATION CHECKLIST

- [ ] DOMAINS.md created in project root
- [ ] All 12 domains specified
- [ ] Ownership patterns for each domain
- [ ] Cross-domain rules documented
- [ ] Dependency graph included
- [ ] validate-domains.ts script created
- [ ] Pre-commit hook added
- [ ] PM Validator Section S added

---

# ESTIMATED EFFORT

| Task | Hours |
|------|-------|
| Create DOMAINS.md | 1.0 |
| Create validation script | 1.0 |
| Add pre-commit hook | 0.5 |
| Add PM Validator checks | 0.5 |
| **Total** | **3.0 hours** |

---

**Category 5: Domain Architecture - Gap Analysis Complete**

**CRITICAL FINDING:** DOMAINS.md does not exist. Complete specification is in ISSUE-03-DOMAINS-MD-MISSING.md but needs to be extracted and implemented.

**Next:** Category 6: Multi-Agent Orchestration
