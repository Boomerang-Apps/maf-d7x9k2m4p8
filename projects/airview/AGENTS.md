# AirView Agent Definitions
## MAF V11.0.0 Project-Specific Configuration

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - https://raw.githubusercontent.com/Boomerang-Apps/maf-d7x9k2m4p8/main/core/AGENTS.md
  
This file is PROJECT-SPECIFIC (not framework core).
It defines the agents for the AirView marketplace application.
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0  
**Project:** AirView Marketplace  
**Total Agents:** 29

---

## Agent Summary

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
                              ┌─────────┐
                              │   CTO   │ ◄── Master Authority
                              │ (Opus)  │     Gate 0 + Gate 7
                              └────┬────┘
                                   │
                              ┌────▼────┐
                              │   PM    │ ◄── Orchestration
                              │ (Opus)  │     Gate 5
                              └────┬────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         │                         │                         │
    ┌────▼────┐              ┌────▼────┐              ┌────▼────┐
    │ Dev FE  │              │ Dev BE  │              │   QA    │
    │(Sonnet) │              │(Sonnet) │              │(Haiku)  │
    │ x10     │              │ x10     │              │ x5      │
    └─────────┘              └─────────┘              └─────────┘
    Gate 1,2,3               Gate 1,2,3               Gate 4
```

---

## Management Agents

### CTO Agent

| Field | Value |
|-------|-------|
| Agent Code | `cto` |
| Agent Type | Management |
| Model | claude-opus-4-5-20251101 |
| Domain | All (global authority) |
| Gates Owned | Gate 0 (Research), Gate 7 (Merge) |

**Authority:**
- ✅ Architecture decisions and approval
- ✅ Final merge to main branch (ONLY CTO)
- ✅ Override authority for all agent decisions
- ✅ Emergency stop authorization

### PM Agent

| Field | Value |
|-------|-------|
| Agent Code | `pm` |
| Agent Type | Management |
| Model | claude-opus-4-5-20251101 |
| Domain | All (coordination) |
| Gates Owned | Gate 5 (PM Review) |

**Authority:**
- ✅ Story assignment and tracking
- ✅ Wave orchestration
- ✅ Code review and standards check

---

## Frontend Dev Agents (10)

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

**Model:** claude-sonnet-4-20250514  
**Gates Owned:** Gate 1 (Planning), Gate 2 (Building), Gate 3 (Self-Test)

---

## Backend Dev Agents (10)

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

**Model:** claude-sonnet-4-20250514  
**Gates Owned:** Gate 1 (Planning), Gate 2 (Building), Gate 3 (Self-Test)

---

## QA Agents (5)

| Agent Code | Specialty | Covers Domains | Model |
|------------|-----------|----------------|-------|
| `qa-core` | Core validation | CLIENT, PILOT, PROJECT, PROPOSAL, DELIVERABLES, ADMIN, LAYOUT | claude-haiku-4-5-20251001 |
| `qa-auth` | Authentication | AUTH | claude-haiku-4-5-20251001 |
| `qa-transactions` | Financial | PAYMENT | claude-haiku-4-5-20251001 |
| `qa-comms` | Communication | MESSAGING | claude-haiku-4-5-20251001 |
| `qa-integration` | Integration | CORE, cross-domain | claude-haiku-4-5-20251001 |

**Gates Owned:** Gate 4 (QA Validation)

---

## Model Cost Optimization

| Agent Type | Model | Cost per 1M tokens (input/output) |
|------------|-------|-----------------------------------|
| CTO | Opus 4.5 | $15.00 / $75.00 |
| PM | Opus 4.5 | $15.00 / $75.00 |
| Dev (FE/BE) | Sonnet 4 | $3.00 / $15.00 |
| QA | Haiku 4.5 | $0.25 / $1.25 |

**Rationale:** Using Haiku for QA saves ~3x on validation costs while maintaining quality.

---

## Gate Ownership Matrix

| Agent Type | G0 | G1 | G2 | G3 | G4 | G5 | G6 | G7 |
|------------|----|----|----|----|----|----|----|----|
| **CTO** | ✅ | - | - | - | - | - | - | ✅ |
| **PM** | - | - | - | - | - | ✅ | - | - |
| **Dev** | - | ✅ | ✅ | ✅ | - | - | - | - |
| **QA** | - | - | - | - | ✅ | - | - | - |

---

## Quick Reference by Domain

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

---

**Document Status:** PROJECT-SPECIFIC (not LOCKED)
