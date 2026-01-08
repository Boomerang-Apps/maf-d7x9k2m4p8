# MAF APPROVAL LEVELS V11.0.0
## L0-L5 Human Approval Matrix

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - /mnt/project/COMPLETE-SAFETY-REFERENCE.md (90K, lines 235-345)
  
Extraction Method: 
  - Copied approval matrix from PART 2: HUMAN APPROVAL MATRIX
  - Reformatted for V11.0.0 structure
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0  
**Classification:** CORE - Defines approval hierarchy

---

## Approval Level Definitions

| Level | Icon | Who Approves | Response Time | Use Case |
|-------|------|--------------|---------------|----------|
| **L0: FORBIDDEN** | 🚫 | NEVER | N/A | Never allowed |
| **L1: HUMAN ONLY** | 🔴 | Eli (Human) | Immediate | Production, security |
| **L2: CTO APPROVAL** | 🟠 | CTO Agent | < 5 min | Architecture, merge |
| **L3: PM APPROVAL** | 🟡 | PM Agent | < 15 min | Stories, coordination |
| **L4: QA REVIEW** | 🔵 | QA Agent | < 30 min | Code quality |
| **L5: AUTO-ALLOWED** | 🟢 | No approval | Instant | Safe operations |

---

## Complete Approval Matrix

### Database Operations

| Operation | Level | Approver | Conditions |
|-----------|-------|----------|------------|
| DROP DATABASE | 🚫 L0 | NEVER | Forbidden |
| DROP TABLE | 🚫 L0 | NEVER | Forbidden |
| TRUNCATE | 🚫 L0 | NEVER | Forbidden |
| DELETE (mass) | 🚫 L0 | NEVER | Forbidden |
| CREATE TABLE | 🔴 L1 | Human | Production |
| CREATE TABLE | 🟡 L3 | PM | Development |
| ALTER TABLE ADD | 🔴 L1 | Human | Production |
| ALTER TABLE ADD | 🟡 L3 | PM | Development |
| INSERT (test data) | 🟢 L5 | Auto | In test DB |
| SELECT | 🟢 L5 | Auto | Read-only |
| CREATE INDEX | 🟡 L3 | PM | With justification |
| Migration scripts | 🔴 L1 | Human | Always |

### File Operations

| Operation | Level | Approver | Conditions |
|-----------|-------|----------|------------|
| rm -rf [dangerous] | 🚫 L0 | NEVER | Forbidden |
| Delete .env | 🚫 L0 | NEVER | Forbidden |
| Delete .git | 🚫 L0 | NEVER | Forbidden |
| Create file (own domain) | 🟢 L5 | Auto | Within domain |
| Create file (shared) | 🟡 L3 | PM | Shared code |
| Modify file (own domain) | 🟢 L5 | Auto | Within domain |
| Modify file (other domain) | 🚫 L0 | NEVER | Forbidden |
| Delete file (own domain) | 🔵 L4 | QA | With reason |
| Delete file (shared) | 🟡 L3 | PM | With reason |
| Read any file | 🟢 L5 | Auto | Always allowed |

### Git Operations

| Operation | Level | Approver | Conditions |
|-----------|-------|----------|------------|
| git push --force | 🚫 L0 | NEVER | Forbidden |
| git branch -D main | 🚫 L0 | NEVER | Forbidden |
| git rebase (shared) | 🚫 L0 | NEVER | Forbidden |
| git commit | 🟢 L5 | Auto | Feature branch |
| git push (feature) | 🟢 L5 | Auto | Feature branch |
| git checkout -b | 🟢 L5 | Auto | New branch |
| git merge to develop | 🟡 L3 | PM | After QA |
| git merge to main | 🟠 L2 | CTO | After PM |
| Create PR | 🟢 L5 | Auto | Always allowed |
| Delete feature branch | 🟢 L5 | Auto | After merge |
| Create tag | 🟢 L5 | Auto | Checkpoint |

### Deployment

| Operation | Level | Approver | Conditions |
|-----------|-------|----------|------------|
| Deploy to production | 🔴 L1 | Human | Always |
| Deploy to staging | 🟡 L3 | PM | After tests |
| Deploy to dev | 🟢 L5 | Auto | After build |
| Rollback production | 🔴 L1 | Human | Emergency |
| Rollback staging | 🟡 L3 | PM | On failure |
| Config change (prod) | 🔴 L1 | Human | Always |
| Config change (dev) | 🟡 L3 | PM | With reason |

### Security

| Operation | Level | Approver | Conditions |
|-----------|-------|----------|------------|
| Modify auth code | 🔴 L1 | Human | Always |
| Modify payment code | 🔴 L1 | Human | Always |
| Modify encryption | 🔴 L1 | Human | Always |
| Modify session handling | 🔴 L1 | Human | Always |
| Modify access control | 🔴 L1 | Human | Always |
| Add API endpoint | 🟡 L3 | PM | Review scope |
| Modify API permissions | 🔴 L1 | Human | Always |
| Access credentials | 🚫 L0 | NEVER | Forbidden |
| Modify RLS policies | 🔴 L1 | Human | Always |

### Dependencies

| Operation | Level | Approver | Conditions |
|-----------|-------|----------|------------|
| npm install [new] | 🔵 L4 | QA | License check |
| npm update [existing] | 🟢 L5 | Auto | Patch versions |
| npm update [major] | 🟡 L3 | PM | Breaking changes |
| npm uninstall | 🔵 L4 | QA | Verify unused |
| npm audit fix | 🟢 L5 | Auto | Security patches |

### External Communications

| Operation | Level | Approver | Conditions |
|-----------|-------|----------|------------|
| Send email (user) | 🔴 L1 | Human | Always |
| Send SMS (user) | 🔴 L1 | Human | Always |
| Call external API (prod) | 🔴 L1 | Human | With side effects |
| Call external API (test) | 🟢 L5 | Auto | Sandbox only |
| Webhook setup | 🔴 L1 | Human | Always |

---

## Approval Request Format

```json
{
  "request_type": "approval",
  "from_agent": "fe-auth",
  "approval_level": "L3",
  "approver": "pm",
  "operation": "npm install zod",
  "reason": "Need schema validation for login form",
  "risk_assessment": "low",
  "rollback_plan": "npm uninstall zod",
  "timeout_minutes": 30,
  "created_at": "2026-01-08T10:00:00Z"
}
```

---

## Level Decision Tree

```
                    Operation Requested
                           │
                           ▼
              ┌────────────────────────┐
              │ Is it in L0 FORBIDDEN? │
              └────────────────────────┘
                    │           │
                   YES          NO
                    │           │
                    ▼           ▼
               ❌ BLOCK   ┌─────────────────┐
                         │ Affects PROD?   │
                         └─────────────────┘
                              │         │
                             YES        NO
                              │         │
                              ▼         ▼
                         🔴 L1     ┌───────────────┐
                         Human    │ Architecture? │
                                  └───────────────┘
                                       │        │
                                      YES       NO
                                       │        │
                                       ▼        ▼
                                  🟠 L2    ┌───────────────┐
                                  CTO     │ Cross-domain? │
                                          └───────────────┘
                                               │        │
                                              YES       NO
                                               │        │
                                               ▼        ▼
                                          🟡 L3    ┌───────────────┐
                                          PM      │ Quality gate? │
                                                  └───────────────┘
                                                       │        │
                                                      YES       NO
                                                       │        │
                                                       ▼        ▼
                                                  🔵 L4    🟢 L5
                                                  QA      Auto
```

---

## Quick Reference

| Level | Color | When to Use |
|-------|-------|-------------|
| L0 | 🚫 | Destructive, irreversible, security risks |
| L1 | 🔴 | Production, auth, payment, credentials |
| L2 | 🟠 | Architecture decisions, main branch |
| L3 | 🟡 | Cross-domain, dependencies, coordination |
| L4 | 🔵 | Quality reviews, code changes |
| L5 | 🟢 | Safe, reversible, within domain |

---

**Document Status:** LOCKED  
**Last Updated:** 2026-01-08  
**Source:** COMPLETE-SAFETY-REFERENCE.md
