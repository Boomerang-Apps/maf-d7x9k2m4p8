# AirView Domain Definitions
## MAF V11.0.0 Project-Specific Configuration

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - https://raw.githubusercontent.com/Boomerang-Apps/maf-d7x9k2m4p8/main/core/DOMAINS.md
  
This file is PROJECT-SPECIFIC (not framework core).
It defines the domains for the AirView marketplace application.
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0  
**Project:** AirView Marketplace  
**Total Domains:** 11

---

## Domain Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AIRVIEW DOMAIN MAP                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CORE DOMAINS                    SUPPORTING DOMAINS                         │
│  ─────────────                   ──────────────────                         │
│                                                                             │
│  ┌─────────┐  ┌─────────┐       ┌─────────┐  ┌─────────┐                   │
│  │  AUTH   │  │ CLIENT  │       │ PAYMENT │  │MESSAGING│                   │
│  │         │  │         │       │         │  │         │                   │
│  │ Login   │  │ Browse  │       │ Stripe  │  │  Chat   │                   │
│  │ Register│  │ Search  │       │Invoices │  │  Notif  │                   │
│  │ Profile │  │ Booking │       │         │  │         │                   │
│  └─────────┘  └─────────┘       └─────────┘  └─────────┘                   │
│                                                                             │
│  ┌─────────┐  ┌─────────┐       ┌─────────┐  ┌─────────┐                   │
│  │  PILOT  │  │ PROJECT │       │DELIVRBL │  │  ADMIN  │                   │
│  │         │  │         │       │         │  │         │                   │
│  │ Profile │  │ Create  │       │  Files  │  │Dashboard│                   │
│  │ Jobs    │  │ Manage  │       │  Review │  │  Users  │                   │
│  │ Schedule│  │ Assign  │       │  Approve│  │ Reports │                   │
│  └─────────┘  └─────────┘       └─────────┘  └─────────┘                   │
│                                                                             │
│  ┌─────────┐  ┌─────────┐       ┌─────────┐                                │
│  │PROPOSAL │  │ LAYOUT  │       │  CORE   │                                │
│  │         │  │         │       │         │                                │
│  │ Create  │  │   UI    │       │Supabase │                                │
│  │ Submit  │  │ Common  │       │  Utils  │                                │
│  │ Review  │  │ Shared  │       │ Shared  │                                │
│  └─────────┘  └─────────┘       └─────────┘                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Domain Definitions

### 1. AUTH Domain

**Purpose:** User authentication, authorization, and identity management

| Property | Value |
|----------|-------|
| Domain Code | `auth` |
| Frontend Agent | fe-auth |
| Backend Agent | be-auth |
| QA Agent | qa-auth |
| Security Level | HIGH |

**Owned Paths:**
```
Frontend:
  - src/app/auth/**
  - src/components/auth/**
  - src/hooks/useAuth.ts

Backend:
  - src/app/api/auth/**
  - src/lib/auth/**

Contracts:
  - contracts/auth.ts
```

**Forbidden Paths:**
```
  - .env*
  - src/lib/supabase/client.ts (read-only)
```

---

### 2. CLIENT Domain

**Purpose:** Client-side user experience, browsing, searching

| Property | Value |
|----------|-------|
| Domain Code | `client` |
| Frontend Agent | fe-client |
| Backend Agent | be-client |
| QA Agent | qa-core |
| Security Level | MEDIUM |

**Owned Paths:**
```
Frontend:
  - src/app/client/**
  - src/components/client/**
  - src/app/(client)/**

Backend:
  - src/app/api/clients/**
  - src/lib/client/**

Contracts:
  - contracts/client.ts
```

---

### 3. PILOT Domain

**Purpose:** Pilot profiles, scheduling, job management

| Property | Value |
|----------|-------|
| Domain Code | `pilot` |
| Frontend Agent | fe-pilot |
| Backend Agent | be-pilot |
| QA Agent | qa-core |
| Security Level | MEDIUM |

**Owned Paths:**
```
Frontend:
  - src/app/pilot/**
  - src/components/pilot/**
  - src/app/(pilot)/**

Backend:
  - src/app/api/pilots/**
  - src/lib/pilot/**

Contracts:
  - contracts/pilot.ts
```

---

### 4. PROJECT Domain

**Purpose:** Project creation, management, assignment

| Property | Value |
|----------|-------|
| Domain Code | `project` |
| Frontend Agent | fe-project |
| Backend Agent | be-project |
| QA Agent | qa-core |
| Security Level | MEDIUM |

**Owned Paths:**
```
Frontend:
  - src/app/projects/**
  - src/components/project/**

Backend:
  - src/app/api/projects/**
  - src/lib/project/**

Contracts:
  - contracts/project.ts
```

---

### 5. PROPOSAL Domain

**Purpose:** Proposal creation, submission, review

| Property | Value |
|----------|-------|
| Domain Code | `proposal` |
| Frontend Agent | fe-proposal |
| Backend Agent | be-proposal |
| QA Agent | qa-core |
| Security Level | MEDIUM |

**Owned Paths:**
```
Frontend:
  - src/app/proposals/**
  - src/components/proposal/**

Backend:
  - src/app/api/proposals/**
  - src/lib/proposal/**

Contracts:
  - contracts/proposal.ts
```

---

### 6. PAYMENT Domain

**Purpose:** Payment processing, invoicing, Stripe integration

| Property | Value |
|----------|-------|
| Domain Code | `payment` |
| Frontend Agent | fe-payment |
| Backend Agent | be-payment |
| QA Agent | qa-transactions |
| Security Level | **CRITICAL** |

**Owned Paths:**
```
Frontend:
  - src/app/payments/**
  - src/components/payment/**

Backend:
  - src/app/api/payments/**
  - src/lib/stripe/**

Contracts:
  - contracts/payment.ts
```

**Special Rules:**
- All changes require L1 (Human) approval
- QA must verify no hardcoded credentials
- Stripe webhook handlers need security review

---

### 7. DELIVERABLES Domain

**Purpose:** File management, review, approval

| Property | Value |
|----------|-------|
| Domain Code | `deliverables` |
| Frontend Agent | fe-deliverables |
| Backend Agent | be-deliverables |
| QA Agent | qa-core |
| Security Level | MEDIUM |

**Owned Paths:**
```
Frontend:
  - src/app/deliverables/**
  - src/components/deliverables/**

Backend:
  - src/app/api/deliverables/**
  - src/lib/storage/**

Contracts:
  - contracts/deliverables.ts
```

---

### 8. MESSAGING Domain

**Purpose:** Real-time chat, notifications

| Property | Value |
|----------|-------|
| Domain Code | `messaging` |
| Frontend Agent | fe-messaging |
| Backend Agent | be-messaging |
| QA Agent | qa-comms |
| Security Level | MEDIUM |

**Owned Paths:**
```
Frontend:
  - src/app/messages/**
  - src/components/messaging/**

Backend:
  - src/app/api/messages/**
  - src/lib/realtime/**

Contracts:
  - contracts/messaging.ts
```

---

### 9. ADMIN Domain

**Purpose:** Admin dashboard, user management, reporting

| Property | Value |
|----------|-------|
| Domain Code | `admin` |
| Frontend Agent | fe-admin |
| Backend Agent | be-admin |
| QA Agent | qa-core |
| Security Level | HIGH |

**Owned Paths:**
```
Frontend:
  - src/app/admin/**
  - src/components/admin/**

Backend:
  - src/app/api/admin/**
  - src/lib/admin/**

Contracts:
  - contracts/admin.ts
```

---

### 10. LAYOUT Domain

**Purpose:** Shared UI components, layouts

| Property | Value |
|----------|-------|
| Domain Code | `layout` |
| Frontend Agent | fe-layout |
| Backend Agent | N/A |
| QA Agent | qa-core |
| Security Level | LOW |

**Owned Paths:**
```
Frontend:
  - src/components/ui/**
  - src/components/layout/**
  - src/app/layout.tsx
```

---

### 11. CORE Domain

**Purpose:** Shared infrastructure, utilities

| Property | Value |
|----------|-------|
| Domain Code | `core` |
| Frontend Agent | N/A |
| Backend Agent | be-core |
| QA Agent | qa-integration |
| Security Level | HIGH |

**Owned Paths:**
```
Backend:
  - src/lib/supabase/**
  - src/lib/utils/**
  - src/lib/db/**

Contracts:
  - contracts/shared.ts
```

**Special Rules:**
- Changes affect all other domains
- Requires CTO approval for modifications
- Must have integration tests

---

## Domain Dependencies

```
                    ┌──────────┐
                    │   CORE   │
                    │ (shared) │
                    └────┬─────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │  AUTH   │     │ LAYOUT  │     │PAYMENT  │
   │         │     │         │     │         │
   └────┬────┘     └────┬────┘     └────┬────┘
        │               │               │
        │    ┌──────────┴──────────┐    │
        │    │                     │    │
        ▼    ▼                     ▼    ▼
   ┌─────────────┐           ┌─────────────┐
   │   CLIENT    │           │   PILOT     │
   │  PROPOSAL   │           │   PROJECT   │
   │ DELIVERABLES│           │   ADMIN     │
   │  MESSAGING  │           │             │
   └─────────────┘           └─────────────┘
```

---

## Cross-Domain Communication

Domains communicate through contracts:

```typescript
// contracts/shared.ts - CORE exports
export interface User { ... }
export interface AuthContext { ... }

// contracts/project.ts - PROJECT uses AUTH
import { User } from './shared';
export interface Project { owner: User; ... }
```

---

## Security Levels

| Level | Domains | Approval Required |
|-------|---------|-------------------|
| CRITICAL | PAYMENT | L1 (Human) |
| HIGH | AUTH, ADMIN, CORE | L2 (CTO) |
| MEDIUM | CLIENT, PILOT, PROJECT, PROPOSAL, DELIVERABLES, MESSAGING | L3 (PM) |
| LOW | LAYOUT | L5 (Auto) |

---

**Document Status:** PROJECT-SPECIFIC (not LOCKED)
