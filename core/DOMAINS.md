# AirView Domain Definitions

> **Version:** 1.0  
> **Last Updated:** January 7, 2026  
> **Purpose:** Define domain boundaries, ownership, and communication rules for multi-agent development

## Overview

AirView is organized into **12 domains**, each with clear boundaries, ownership, and communication rules. This document is the authoritative source for domain architecture and must be consulted before any cross-domain work.

| Domain | Type | Level | Team Size | Description |
|--------|------|-------|-----------|-------------|
| AUTH | Foundational | 0 | 2 dev + 1 QA | User authentication & authorization |
| LAYOUT | Foundational | 0 | 1 dev + 1 QA | UI framework & design system |
| CORE | Foundational | 0 | 1 dev + 1 QA | Shared infrastructure |
| CLIENT | Entity | 1 | 2 dev + 1 QA | Customer management |
| PILOT | Entity | 1 | 2 dev + 1 QA | Drone pilot management |
| PROJECT | Business | 2 | 2 dev + 1 QA | Job/project lifecycle |
| PROPOSAL | Business | 2 | 2 dev + 1 QA | Quotes & proposals |
| PAYMENT | Business | 2 | 2 dev + 1 QA | Invoicing & payments |
| DELIVERABLES | Business | 2 | 2 dev + 1 QA | File uploads & reviews |
| MESSAGING | Support | 3 | 2 dev + 1 QA | Real-time chat |
| ADMIN | Support | 3 | 2 dev + 1 QA | System administration |
| NOTIFICATIONS | Support | 3 | Shared | Alerts & notifications |

---

## Domain Hierarchy

The hierarchy defines dependency flow. Higher-level domains can depend on lower-level domains, but never the reverse.

```
┌─────────────────────────────────────────────────────────────────────┐
│ LEVEL 0: FOUNDATIONAL DOMAINS                                       │
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                      │
│  │   AUTH   │    │  LAYOUT  │    │   CORE   │                      │
│  │ (users)  │    │   (UI)   │    │ (infra)  │                      │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘                      │
│       │               │               │                            │
│  Depends on: NOTHING                                                │
│  Consumed by: ALL                                                   │
└───────┼───────────────┼───────────────┼────────────────────────────┘
        │               │               │
┌───────┴───────────────┴───────────────┴────────────────────────────┐
│ LEVEL 1: ENTITY DOMAINS                                             │
│                                                                     │
│  ┌──────────┐    ┌──────────┐                                      │
│  │  CLIENT  │    │  PILOT   │                                      │
│  │(customers)│   │ (drone   │                                      │
│  │          │    │  pilots) │                                      │
│  └────┬─────┘    └────┬─────┘                                      │
│       │               │                                             │
│  Depends on: AUTH                                                   │
│  Consumed by: PROJECT, PROPOSAL, MESSAGING                         │
└───────┼───────────────┼────────────────────────────────────────────┘
        │               │
┌───────┴───────────────┴────────────────────────────────────────────┐
│ LEVEL 2: BUSINESS DOMAINS                                           │
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐         │
│  │ PROJECT  │──│ PROPOSAL │──│ PAYMENT  │  │DELIVERABLES│         │
│  │  (jobs)  │  │ (quotes) │  │(invoices)│  │  (files)   │         │
│  └────┬─────┘  └──────────┘  └──────────┘  └────────────┘         │
│       │                                                             │
│  Depends on: CLIENT, PILOT, AUTH                                    │
│  Consumed by: ADMIN, MESSAGING                                      │
└───────┼────────────────────────────────────────────────────────────┘
        │
┌───────┴────────────────────────────────────────────────────────────┐
│ LEVEL 3: SUPPORT DOMAINS                                            │
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐                  │
│  │MESSAGING │    │  ADMIN   │    │ NOTIFICATIONS│                  │
│  │  (chat)  │    │(settings)│    │   (alerts)   │                  │
│  └──────────┘    └──────────┘    └──────────────┘                  │
│                                                                     │
│  Depends on: ALL (can reference any domain via contracts)           │
│  Consumed by: NONE (terminal domains)                               │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Domain Definitions

### Domain: AUTH

**Type:** Foundational  
**Level:** 0  
**Responsibility:** User authentication, authorization, session management  
**Agents:** fe-auth, be-auth  
**QA:** qa-auth

#### Boundaries

```yaml
frontend:
  - src/app/auth/**
  - src/app/(auth)/**
  - src/components/auth/**
  - src/hooks/useAuth.ts
  - src/hooks/useSession.ts
  - src/hooks/useUser.ts

backend:
  - src/app/api/auth/**
  - src/lib/auth/**

database:
  - supabase/migrations/*auth*
  - supabase/migrations/*user*
  - supabase/migrations/*session*
```

#### Provides (via contracts)

- `User` type
- `AuthSession` type
- `AuthRole` enum
- `AuthAPI` interface

#### Consumes

- Nothing (foundational)

#### Cross-Domain Rules

- Other domains import `User` type from `contracts/entities/user.ts`
- Other domains check auth via `useSession()` hook
- **NEVER** import directly from `src/components/auth/*`

---

### Domain: LAYOUT

**Type:** Foundational  
**Level:** 0  
**Responsibility:** UI framework, design system, shared components  
**Agents:** fe-layout  
**QA:** qa-integration

#### Boundaries

```yaml
frontend:
  - src/components/layout/**
  - src/components/ui/**
  - src/components/shared/**
  - src/components/common/**
  - src/app/layout.tsx
  - src/app/globals.css
  - src/styles/**
```

#### Provides

- `Button`, `Input`, `Card`, etc. (UI primitives)
- `Header`, `Sidebar`, `Footer` (layout components)
- Theme configuration
- CSS variables

#### Consumes

- Nothing (foundational)

#### Cross-Domain Rules

- All domains CAN import from `src/components/ui/*`
- All domains CAN import from `src/components/layout/*`
- Only fe-layout CAN MODIFY these components

---

### Domain: CORE

**Type:** Foundational  
**Level:** 0  
**Responsibility:** Shared infrastructure, database client, utilities  
**Agents:** be-core  
**QA:** qa-integration

#### Boundaries

```yaml
backend:
  - src/app/api/core/**
  - src/app/api/health/**
  - src/lib/supabase/**
  - src/lib/utils/**
  - src/lib/helpers/**
  - src/lib/validators/**

database:
  - supabase/migrations/*core*
  - supabase/migrations/*init*
  - supabase/config.toml
  - supabase/seed.sql
```

#### Provides

- Supabase client
- Utility functions
- Validation helpers
- Error handling

#### Consumes

- Nothing (foundational)

#### Cross-Domain Rules

- All backend agents CAN use `src/lib/supabase/client.ts`
- All agents CAN use `src/lib/utils/*`
- Only be-core CAN MODIFY these files

---

### Domain: CLIENT

**Type:** Entity  
**Level:** 1  
**Responsibility:** Client/customer management, profiles, settings  
**Agents:** fe-client, be-client  
**QA:** qa-core

#### Boundaries

```yaml
frontend:
  - src/app/client/**
  - src/app/(dashboard)/client/**
  - src/components/client/**
  - src/hooks/useClient.ts
  - src/hooks/useClients.ts

backend:
  - src/app/api/clients/**
  - src/lib/client/**

database:
  - supabase/migrations/*client*
```

#### Provides (via contracts)

- `Client` type
- `ClientProfile` type
- `ClientPreferences` type

#### Consumes

- `User` from AUTH

#### Cross-Domain Rules

- PROJECT domain references `Client` via contracts
- MESSAGING domain references `Client` via contracts
- **NEVER** import from `src/components/client/*` outside client domain

---

### Domain: PILOT

**Type:** Entity  
**Level:** 1  
**Responsibility:** Drone pilot management, certifications, equipment  
**Agents:** fe-pilot, be-pilot  
**QA:** qa-core

#### Boundaries

```yaml
frontend:
  - src/app/pilot/**
  - src/app/(dashboard)/pilot/**
  - src/components/pilot/**
  - src/hooks/usePilot.ts
  - src/hooks/useEquipment.ts

backend:
  - src/app/api/pilots/**
  - src/app/api/equipment/**
  - src/lib/pilot/**

database:
  - supabase/migrations/*pilot*
  - supabase/migrations/*equipment*
```

#### Provides (via contracts)

- `Pilot` type
- `Equipment` type
- `Certification` type

#### Consumes

- `User` from AUTH

#### Cross-Domain Rules

- PROJECT domain references `Pilot` via contracts
- PROPOSAL domain references `Pilot` via contracts
- **NEVER** import from `src/components/pilot/*` outside pilot domain

---

### Domain: PROJECT

**Type:** Business  
**Level:** 2  
**Responsibility:** Project lifecycle, assignments, tracking  
**Agents:** fe-project, be-project  
**QA:** qa-core

#### Boundaries

```yaml
frontend:
  - src/app/projects/**
  - src/app/(dashboard)/projects/**
  - src/components/project/**
  - src/hooks/useProject.ts
  - src/hooks/useProjects.ts

backend:
  - src/app/api/projects/**
  - src/lib/project/**

database:
  - supabase/migrations/*project*
```

#### Provides (via contracts)

- `Project` type
- `ProjectStatus` enum
- `Assignment` type

#### Consumes

- `Client` from CLIENT
- `Pilot` from PILOT
- `User` from AUTH

#### Cross-Domain Rules

- PROPOSAL references `Project` via contracts
- DELIVERABLES references `Project` via contracts
- PAYMENT references `Project` via contracts

---

### Domain: PROPOSAL

**Type:** Business  
**Level:** 2  
**Responsibility:** Quotes, proposals, negotiations  
**Agents:** fe-proposal, be-proposal  
**QA:** qa-transactions

#### Boundaries

```yaml
frontend:
  - src/app/proposals/**
  - src/app/(dashboard)/proposals/**
  - src/components/proposal/**
  - src/hooks/useProposal.ts
  - src/hooks/useQuote.ts

backend:
  - src/app/api/proposals/**
  - src/app/api/quotes/**
  - src/lib/proposal/**

database:
  - supabase/migrations/*proposal*
  - supabase/migrations/*quote*
```

#### Provides (via contracts)

- `Proposal` type
- `Quote` type
- `ProposalStatus` enum

#### Consumes

- `Project` from PROJECT
- `Client` from CLIENT
- `Pilot` from PILOT

---

### Domain: PAYMENT

**Type:** Business  
**Level:** 2  
**Responsibility:** Invoicing, payments, Stripe integration  
**Agents:** fe-payment, be-payment  
**QA:** qa-transactions

#### Boundaries

```yaml
frontend:
  - src/app/payments/**
  - src/app/(dashboard)/payments/**
  - src/app/(dashboard)/invoices/**
  - src/components/payment/**
  - src/hooks/usePayment.ts
  - src/hooks/useInvoice.ts

backend:
  - src/app/api/payments/**
  - src/app/api/invoices/**
  - src/app/api/stripe/**
  - src/lib/payment/**
  - src/lib/stripe/**

database:
  - supabase/migrations/*payment*
  - supabase/migrations/*invoice*
  - supabase/migrations/*transaction*
```

#### Provides (via contracts)

- `Invoice` type
- `Payment` type
- `Transaction` type
- `PaymentStatus` enum

#### Consumes

- `Project` from PROJECT
- `Proposal` from PROPOSAL
- `Client` from CLIENT

---

### Domain: DELIVERABLES

**Type:** Business  
**Level:** 2  
**Responsibility:** File uploads, reviews, approvals, delivery  
**Agents:** fe-deliverables, be-deliverables  
**QA:** qa-integration

#### Boundaries

```yaml
frontend:
  - src/app/deliverables/**
  - src/app/(dashboard)/deliverables/**
  - src/components/deliverables/**
  - src/components/files/**
  - src/hooks/useDeliverables.ts
  - src/hooks/useUpload.ts

backend:
  - src/app/api/deliverables/**
  - src/app/api/files/**
  - src/lib/deliverables/**
  - src/lib/storage/**

database:
  - supabase/migrations/*deliverable*
  - supabase/migrations/*file*
```

#### Provides (via contracts)

- `Deliverable` type
- `Review` type
- `DeliverableStatus` enum

#### Consumes

- `Project` from PROJECT
- `Client` from CLIENT
- `Pilot` from PILOT

---

### Domain: MESSAGING

**Type:** Support  
**Level:** 3  
**Responsibility:** Real-time chat, notifications, communication  
**Agents:** fe-messaging, be-messaging  
**QA:** qa-comms

#### Boundaries

```yaml
frontend:
  - src/app/messages/**
  - src/app/(dashboard)/messages/**
  - src/components/messaging/**
  - src/components/chat/**
  - src/hooks/useMessages.ts
  - src/hooks/useConversation.ts

backend:
  - src/app/api/messages/**
  - src/app/api/conversations/**
  - src/lib/messaging/**
  - src/lib/realtime/**

database:
  - supabase/migrations/*message*
  - supabase/migrations/*conversation*
```

#### Provides (via contracts)

- `Conversation` type
- `Message` type

#### Consumes

- `User` from AUTH
- `Project` from PROJECT
- `Client` from CLIENT
- `Pilot` from PILOT

---

### Domain: ADMIN

**Type:** Support  
**Level:** 3  
**Responsibility:** System administration, user management, settings  
**Agents:** fe-admin, be-admin  
**QA:** qa-integration

#### Boundaries

```yaml
frontend:
  - src/app/admin/**
  - src/app/(dashboard)/admin/**
  - src/components/admin/**
  - src/hooks/useAdmin.ts
  - src/hooks/useSettings.ts

backend:
  - src/app/api/admin/**
  - src/app/api/settings/**
  - src/lib/admin/**

database:
  - supabase/migrations/*admin*
  - supabase/migrations/*settings*
```

#### Provides

- Admin settings API
- User management API
- System configuration

#### Consumes

- All domains (read-only for admin purposes)

---

### Domain: NOTIFICATIONS

**Type:** Support  
**Level:** 3  
**Responsibility:** Alerts, notifications, event broadcasting  
**Agents:** Shared (be-core typically handles)  
**QA:** qa-integration

#### Boundaries

```yaml
frontend:
  - src/components/notifications/**
  - src/hooks/useNotifications.ts

backend:
  - src/app/api/notifications/**
  - src/lib/notifications/**

database:
  - supabase/migrations/*notification*
```

#### Provides

- `Notification` type
- Push notification service
- Email notification service

#### Consumes

- All domains (can receive events from any domain)

---

## Cross-Domain Communication Rules

### Rule 1: Use Contracts, Not Direct Imports

```typescript
// ❌ WRONG - Direct import across domains
import { PilotCard } from '@/components/pilot/PilotCard'

// ✅ CORRECT - Use contract types
import type { Pilot } from '@/contracts/entities/pilot'

// ✅ CORRECT - Call API
const pilot = await fetch('/api/pilots/' + pilotId)
```

### Rule 2: API-First for Data

```typescript
// ❌ WRONG - Direct database access from wrong domain
// fe-client trying to query pilots table directly
const pilots = await supabase.from('pilots').select()

// ✅ CORRECT - Use API
const pilots = await fetch('/api/pilots?available=true')
```

### Rule 3: Shared Types via Contracts

```typescript
// contracts/entities/index.ts
export type { User, AuthSession } from './user'
export type { Client, ClientProfile } from './client'
export type { Pilot, Equipment } from './pilot'
export type { Project, ProjectStatus } from './project'
// etc.
```

### Rule 4: Events for Side Effects

```typescript
// ❌ WRONG - Direct cross-domain function call
import { sendNotification } from '@/lib/messaging'
sendNotification(userId, 'Payment received')

// ✅ CORRECT - Emit event, let messaging domain handle
await supabase.from('events').insert({
  type: 'payment.completed',
  payload: { userId, amount, projectId }
})
// Messaging domain has a listener for 'payment.*' events
```

---

## Dependency Graph

```
                    AUTH
                      │
          ┌───────────┴───────────┐
          │                       │
        CLIENT                  PILOT
          │                       │
          └───────────┬───────────┘
                      │
                   PROJECT
                      │
          ┌───────────┼───────────┐
          │           │           │
       PROPOSAL    PAYMENT   DELIVERABLES
          │           │           │
          └───────────┴───────────┘
                      │
               ┌──────┴──────┐
               │             │
           MESSAGING      ADMIN
               │             │
               └──────┬──────┘
                      │
              NOTIFICATIONS

LEGEND:
────────  "depends on" (can consume types from)
```

---

## Domain Validation

### Manual Check

```bash
# Check for cross-domain imports
grep -r "from '@/components/" src/components/ | grep -v test | grep -v ".test."

# Should only find imports within same domain
# e.g., src/components/auth/LoginForm.tsx importing from src/components/auth/
```

### Validation Rules

1. Files in `src/components/{domain}/` can only import from:
   - Same domain: `src/components/{domain}/*`
   - UI components: `src/components/ui/*`
   - Layout components: `src/components/layout/*`
   - Contracts: `contracts/*`

2. Backend files can only access:
   - Own domain's tables
   - Shared utilities from `src/lib/utils/*`
   - Supabase client from `src/lib/supabase/*`

3. All cross-domain data access must go through APIs

---

## Adding a New Domain

If you need to add a new domain:

1. **Define boundaries** - Add section to this DOMAINS.md
2. **Add ownership** - Update OWNERSHIP-MAP.yaml
3. **Create contracts** - Add types to `contracts/entities/`
4. **Define agents** - Create in `.claudecode/agents/`
5. **Create stories** - Add to sprint planning
6. **Update dependency graph** - Modify this document

---

## Quick Reference: Domain Lookup

| If working on... | You're in domain... | Can import from... |
|-----------------|---------------------|-------------------|
| Login page | AUTH | ui, layout, contracts |
| User profile | AUTH | ui, layout, contracts |
| Client list | CLIENT | ui, layout, contracts, auth |
| Pilot dashboard | PILOT | ui, layout, contracts, auth |
| Project details | PROJECT | ui, layout, contracts, auth, client, pilot |
| Quote builder | PROPOSAL | ui, layout, contracts, auth, client, pilot, project |
| Invoice page | PAYMENT | ui, layout, contracts, auth, client, project, proposal |
| File upload | DELIVERABLES | ui, layout, contracts, auth, client, pilot, project |
| Chat window | MESSAGING | ui, layout, contracts, all domains (via contracts) |
| Admin panel | ADMIN | ui, layout, contracts, all domains (read-only) |
| Toast alerts | NOTIFICATIONS | ui, layout, contracts, all domains (event listeners) |

---

**End of Document**
