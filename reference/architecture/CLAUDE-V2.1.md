# CLAUDE.md - Multi-Agent Safety Protocol V2.1

> **Version:** 2.1 (Aerospace-Grade)  
> **Date:** January 7, 2026  
> **Based On:** V10.7 + COMPLETE-SAFETY-REFERENCE.md  
> **Status:** Production Ready

---

## QUICK REFERENCE

| Category | Count | Reference |
|----------|-------|-----------|
| Forbidden Operations | 108 | Section 1 |
| Approval Levels | 6 | Section 2 |
| Gate System | 8 Gates | Section 3 |
| Emergency Levels | E1-E5 | Section 4 |
| Quick Approvals | Matrix | Section 5 |

---

# SECTION 1: FORBIDDEN OPERATIONS (108 Total)

## 1.1 Database Destruction (12 operations)

These commands are **ABSOLUTELY FORBIDDEN** under all circumstances.

| # | Command Pattern | Risk | Why Forbidden |
|---|----------------|------|---------------|
| 1 | `DROP DATABASE [any]` | Data Loss | Destroys entire database |
| 2 | `DROP TABLE [any]` | Data Loss | Destroys table and all data |
| 3 | `DROP SCHEMA [any]` | Data Loss | Destroys schema and contents |
| 4 | `DROP INDEX [any]` | Performance | Can cripple queries |
| 5 | `TRUNCATE TABLE [any]` | Data Loss | Deletes all rows instantly |
| 6 | `TRUNCATE [any]` | Data Loss | Same as above |
| 7 | `DELETE FROM [table]` (no WHERE) | Data Loss | Mass deletion |
| 8 | `DELETE FROM [table] WHERE 1=1` | Data Loss | Mass deletion pattern |
| 9 | `DELETE FROM [table] WHERE true` | Data Loss | Mass deletion pattern |
| 10 | `UPDATE [table] SET ...` (no WHERE) | Data Corruption | Mass update |
| 11 | `ALTER TABLE ... DROP COLUMN` | Data Loss | Column data lost |
| 12 | `ALTER TABLE ... DROP CONSTRAINT` | Data Integrity | Breaks referential integrity |

**Detection:** Stop if SQL starts with `DROP`, `TRUNCATE`, or has `DELETE`/`UPDATE` without specific `WHERE` clause.

---

## 1.2 File System Destruction (14 operations)

| # | Command Pattern | Risk | Why Forbidden |
|---|----------------|------|---------------|
| 13 | `rm -rf /` | System Destruction | Destroys entire filesystem |
| 14 | `rm -rf ~` | Data Loss | Destroys home directory |
| 15 | `rm -rf .` | Data Loss | Destroys current directory |
| 16 | `rm -rf *` | Data Loss | Destroys all files |
| 17 | `rm -rf /*` | System Destruction | Destroys root contents |
| 18 | `rm -r /` (any variation) | System Destruction | Same as above |
| 19 | `rm -rf /home` | Data Loss | Destroys all users |
| 20 | `rm -rf /var` | System Destruction | Destroys system data |
| 21 | `rm -rf node_modules/` (in root) | Build Break | Must use npm clean |
| 22 | `rm -rf .git` | History Loss | Destroys version control |
| 23 | `rm -rf .env*` | Security Risk | Destroys configuration |
| 24 | `unlink /[critical-path]` | Data Loss | Destroys critical files |
| 25 | `rmdir --ignore-fail-on-non-empty /` | System Destruction | Force delete |
| 26 | `find . -delete` (without specific path) | Data Loss | Mass deletion |

**Also Forbidden:**
- `rm -rf` with any path containing `..`
- `rm` with `-f` flag on multiple files
- Any recursive delete outside agent's domain

---

## 1.3 Git Destruction (11 operations)

| # | Command Pattern | Risk | Why Forbidden |
|---|----------------|------|---------------|
| 27 | `git push --force` | History Loss | Overwrites shared history |
| 28 | `git push -f` | History Loss | Same as above |
| 29 | `git push origin main --force` | History Loss | Destroys main branch |
| 30 | `git push --force-with-lease` (to main) | History Loss | Even lease is dangerous |
| 31 | `git reset --hard origin/main` (on shared) | Code Loss | Destroys local changes |
| 32 | `git clean -fdx` (in root) | Data Loss | Removes all untracked |
| 33 | `git branch -D main` | Branch Loss | Deletes main branch |
| 34 | `git branch -D master` | Branch Loss | Deletes master branch |
| 35 | `git branch --delete --force [protected]` | Branch Loss | Force deletes branch |
| 36 | `git rebase -i` (on shared branch) | History Corruption | Rewrites history |
| 37 | `git filter-branch` | History Corruption | Rewrites entire history |

**Protected Branches (NEVER force push):** `main`, `master`, `develop`, `production`, `staging`

---

## 1.4 Privilege Escalation (10 operations)

| # | Command Pattern | Risk | Why Forbidden |
|---|----------------|------|---------------|
| 38 | `sudo [any command]` | Security | Bypasses permissions |
| 39 | `su [any user]` | Security | Switches user context |
| 40 | `chmod 777 [any path]` | Security | World-writable files |
| 41 | `chmod -R 777` | Security | Recursive world-writable |
| 42 | `chown root [any]` | Security | Changes to root ownership |
| 43 | `chown -R [any system path]` | Security | Mass ownership change |
| 44 | `passwd` | Security | Password modification |
| 45 | `usermod` | Security | User modification |
| 46 | `useradd` | Security | User creation |
| 47 | `visudo` | Security | Sudo configuration |

---

## 1.5 Network & External (10 operations)

| # | Command Pattern | Risk | Why Forbidden |
|---|----------------|------|---------------|
| 48 | `curl [untrusted URL]` | Security | Data exfiltration |
| 49 | `wget [untrusted URL]` | Security | Malicious downloads |
| 50 | `curl \| bash` | Security | Remote code execution |
| 51 | `wget \| sh` | Security | Remote code execution |
| 52 | `curl -o- [URL] \| bash` | Security | Remote code execution |
| 53 | `nc [any]` (netcat) | Security | Network backdoor |
| 54 | `netcat [any]` | Security | Network backdoor |
| 55 | `ssh [external]` | Security | External access |
| 56 | `scp [to external]` | Data Exfiltration | Data transfer out |
| 57 | `rsync [to external]` | Data Exfiltration | Data sync out |

**Allowed Package Registries:** `registry.npmjs.org`, `pypi.org`, `github.com` (for dependencies only)

---

## 1.6 Secrets & Credentials (13 operations)

| # | Command Pattern | Risk | Why Forbidden |
|---|----------------|------|---------------|
| 58 | `cat ~/.ssh/*` | Security | Exposes SSH keys |
| 59 | `cat ~/.env` | Security | Exposes secrets |
| 60 | `cat .env` | Security | Exposes secrets |
| 61 | `cat .env.*` | Security | Exposes secrets |
| 62 | `cat */secrets/*` | Security | Exposes secrets |
| 63 | `cat */credentials/*` | Security | Exposes credentials |
| 64 | `cat */.aws/*` | Security | Exposes AWS keys |
| 65 | `echo $API_KEY` | Security | Prints secrets |
| 66 | `echo $SECRET` | Security | Prints secrets |
| 67 | `printenv \| grep -i key` | Security | Finds secrets |
| 68 | `printenv \| grep -i secret` | Security | Finds secrets |
| 69 | `printenv \| grep -i password` | Security | Finds passwords |
| 70 | `env \| grep -i token` | Security | Finds tokens |

**NEVER:** Print secrets to console, commit secrets to git, include secrets in error messages, log API keys or tokens.

---

## 1.7 System Damage (10 operations)

| # | Command Pattern | Risk | Why Forbidden |
|---|----------------|------|---------------|
| 71 | `shutdown` | Availability | Stops system |
| 72 | `reboot` | Availability | Restarts system |
| 73 | `halt` | Availability | Halts system |
| 74 | `init 0` | Availability | Shutdown |
| 75 | `init 6` | Availability | Reboot |
| 76 | `kill -9 -1` | Availability | Kills all processes |
| 77 | `killall` | Availability | Mass process kill |
| 78 | `pkill [system process]` | Availability | System process kill |
| 79 | `systemctl stop [critical]` | Availability | Stops critical service |
| 80 | `service [critical] stop` | Availability | Stops critical service |

---

## 1.8 Package Publishing (6 operations)

| # | Command Pattern | Risk | Why Forbidden |
|---|----------------|------|---------------|
| 81 | `npm publish` | Supply Chain | Public package release |
| 82 | `yarn publish` | Supply Chain | Public package release |
| 83 | `pip upload` | Supply Chain | Public package release |
| 84 | `twine upload` | Supply Chain | Python package release |
| 85 | `gem push` | Supply Chain | Ruby package release |
| 86 | `cargo publish` | Supply Chain | Rust package release |

---

## 1.9 Production Operations (8 operations)

| # | Operation | Risk | Why Forbidden |
|---|-----------|------|---------------|
| 87 | Deploy to production | User Impact | Affects real users |
| 88 | Modify production config | Availability | Can cause outages |
| 89 | Update production env vars | Security | Credential exposure |
| 90 | Change production API keys | Security | Service disruption |
| 91 | Production database access | Data Integrity | Real data at risk |
| 92 | Modify production DNS | Availability | Service unreachable |
| 93 | Update SSL certificates | Security | HTTPS failures |
| 94 | Cloud resource creation/deletion | Cost/Availability | Billing and outages |

---

## 1.10 Cross-Domain Violations (14 operations)

| # | Operation | Risk | Why Forbidden |
|---|-----------|------|---------------|
| 95 | Import components from other domain | Architecture | Breaks isolation |
| 96 | Modify files in other domain | Ownership | Not your domain |
| 97 | Direct DB access to other domain tables | Data Integrity | Use API instead |
| 98 | Bypass contract types | Architecture | Breaks type safety |
| 99 | Delete shared files without approval | Coordination | Breaks other agents |
| 100 | Merge to main without CTO approval | Process | Requires review |
| 101 | Skip QA validation | Quality | Must have tests |
| 102 | Ignore gate requirements | Process | Gates are mandatory |
| 103 | Create files outside assigned scope | Scope Creep | Stay in lane |
| 104 | Modify auth/payment code (non-auth agent) | Security | Critical domains |
| 105 | Access credentials programmatically | Security | Secrets management |
| 106 | Skip rollback plan creation | Safety | Required for merge |
| 107 | Deploy without smoke test | Quality | Must verify |
| 108 | Ignore stuck detection signals | Safety | Must respond |

---

## 1.11 Summary

| Category | Count | Examples |
|----------|-------|----------|
| Database Destruction | 12 | DROP, DELETE, TRUNCATE |
| File System Destruction | 14 | rm -rf, unlink |
| Git Destruction | 11 | force push, branch delete |
| Privilege Escalation | 10 | sudo, chmod 777 |
| Network & External | 10 | curl \| bash, ssh external |
| Secrets & Credentials | 13 | cat .env, echo $SECRET |
| System Damage | 10 | shutdown, kill -9 -1 |
| Package Publishing | 6 | npm publish |
| Production Operations | 8 | deploy, config change |
| Cross-Domain Violations | 14 | import from other domain |
| **TOTAL** | **108** | All require human approval |

---

# SECTION 2: APPROVAL LEVELS

## 2.1 Approval Level Definitions

| Level | Icon | Who Approves | Response Time | Use Case |
|-------|------|--------------|---------------|----------|
| **L0: FORBIDDEN** | 🚫 | NEVER | N/A | Never allowed |
| **L1: HUMAN ONLY** | 🔴 | Eli (Human) | Immediate | Production, security |
| **L2: CTO APPROVAL** | 🟠 | CTO Agent | < 5 min | Architecture, merge |
| **L3: PM APPROVAL** | 🟡 | PM Agent | < 15 min | Stories, coordination |
| **L4: QA REVIEW** | 🔵 | QA Agent | < 30 min | Code quality |
| **L5: AUTO-ALLOWED** | 🟢 | No approval | Instant | Safe operations |

---

# SECTION 3: 8-GATE SYSTEM

## 3.1 Gate Overview

| Gate | Name | Owner | Key Deliverables | Exit Criteria |
|------|------|-------|------------------|---------------|
| 0 | Research | CTO/PM | Research findings | Approach validated |
| 1 | Planning | Dev | START.md, ROLLBACK-PLAN.md | Plan approved |
| 2 | Build | Dev | Implementation complete | Tests written |
| 3 | Test | Dev/QA | All tests pass | Coverage ≥80% |
| 4 | QA Review | QA | Code review | Quality approved |
| 5 | PM Review | PM | Standards check | Story complete |
| 6 | Integration | Auto | CI/CD pass | No conflicts |
| 7 | Deployment | Human | Production deploy | Smoke tests pass |

---

## 3.2 Gate 1: Planning (UPDATED)

### Required Artifacts

- [ ] **START.md** - Implementation plan (use template)
- [ ] **ROLLBACK-PLAN.md** - Rollback strategy (use template)
- [ ] Feature branch from latest main
- [ ] Git tag: `story/[STORY-ID]/gate-1`

### START.md Requirements

```markdown
# Required Sections:
- Agent (ID, Type, Branch)
- Scope (What will/won't be done)
- Approach (How to implement)
- Files to Create/Modify
- Test Plan
- Dependencies
- Risks with Mitigations
- Time Estimates
```

### ROLLBACK-PLAN.md Requirements

```markdown
# Required Sections:
- Rollback Trigger Conditions
- Rollback Classification (E1-E5)
- Rollback Steps (git revert)
- Database Rollback (if applicable)
- Notification List
- Verification Checklist
```

### Exit Criteria

- [ ] START.md exists and complete
- [ ] ROLLBACK-PLAN.md exists and complete
- [ ] Feature branch created from main
- [ ] Git tag created
- [ ] Inbox updated with Gate 1 completion

---

## 3.3 Gate 3: Test

### Signal Requirements

After tests pass, emit signal:

```sql
INSERT INTO maf_signals (type, story_id, data)
VALUES ('GATE_3_COMPLETE', 'STORY-123', '{
  "coverage": 85,
  "tests_passed": 42,
  "tests_failed": 0,
  "timestamp": "2026-01-07T12:00:00Z"
}');
```

---

## 3.4 Gate 4: QA Review

### Signal Requirements

After QA approval, emit signal:

```sql
INSERT INTO maf_signals (type, story_id, data)
VALUES ('GATE_4_COMPLETE', 'STORY-123', '{
  "qa_agent": "qa-core",
  "issues_found": 0,
  "approved": true,
  "timestamp": "2026-01-07T14:00:00Z"
}');
```

---

## 3.5 Gate 5: PM Review

### Signal Requirements

After PM approval, emit signal:

```sql
INSERT INTO maf_signals (type, story_id, data)
VALUES ('GATE_5_COMPLETE', 'STORY-123', '{
  "pm_agent": "pm-agent",
  "standards_met": true,
  "approved": true,
  "timestamp": "2026-01-07T15:00:00Z"
}');
```

---

## 3.6 Gate 7: Deployment

### Signal Requirements

After successful deployment:

```sql
INSERT INTO maf_signals (type, story_id, data)
VALUES ('GATE_7_COMPLETE', 'STORY-123', '{
  "deployed_by": "human",
  "environment": "production",
  "smoke_tests_passed": true,
  "timestamp": "2026-01-07T18:00:00Z"
}');
```

---

# SECTION 4: EMERGENCY STOP LEVELS

## 4.1 Emergency Level Definitions

| Level | Name | Trigger | Scope | Recovery |
|-------|------|---------|-------|----------|
| **E1** | Agent Stop | Single agent issue | One agent | Restart agent |
| **E2** | Domain Stop | Domain-wide issue | All agents in domain | Restart domain |
| **E3** | Wave Stop | Wave-wide issue | All agents in wave | Restart wave |
| **E4** | System Stop | Critical failure | All agents | Human restart |
| **E5** | Emergency Halt | Security breach | Entire system | Incident response |

---

## 4.2 E1: Single Agent Stop

### Trigger Conditions

- Max iterations (>25) exceeded
- Same error repeated 3+ times
- Token budget exceeded
- Memory > 4GB
- Crash loop (3+ restarts in 15 min)

### Commands

```bash
# Stop single agent
pm2 stop agent-{agent_code}

# Create checkpoint
git tag -a "emergency-stop-{agent}-$(date +%s)" -m "Emergency stop"

# Restart after review
pm2 restart agent-{agent_code}
```

---

## 4.3 E2: Domain Stop

### Trigger Conditions

- Multiple agents in same domain failing
- Domain-wide test failures
- Cross-agent conflicts in domain

### Commands

```bash
# Stop all agents in domain
pm2 stop agent-{domain}-*

# Example: Stop all auth agents
pm2 stop agent-fe-auth agent-be-auth agent-qa-auth
```

---

## 4.4 E3: Wave Stop

### Trigger Conditions

- Budget exceeded (>$100 daily)
- Multiple agents stuck (>3)
- Wave no progress for 60+ minutes
- Critical error pattern detected

### Commands

```bash
# Emergency stop all agents
pm2 stop all

# Update database
psql -c "UPDATE agent_sessions SET status='stopped' WHERE status='running'"
psql -c "UPDATE waves SET status='stopped' WHERE status='running'"

# Create system checkpoint
git tag -a "wave-emergency-$(date +%s)" -m "Emergency wave stop"
```

---

## 4.5 E4: System Stop

### Trigger Conditions

- Database corruption detected
- Infrastructure failure
- Unrecoverable state

### Commands

```bash
# Kill PM2 daemon
pm2 kill

# Preserve state
git stash --all
git commit -am "Emergency system stop checkpoint"
```

---

## 4.6 E5: Emergency Halt (Security Breach)

### Trigger Conditions

- Unauthorized merge detected
- Credentials exposed
- Malicious code detected
- Data breach suspected

### Procedure

1. **IMMEDIATE:** `pkill -9 -f claude` - Force kill all
2. **ISOLATE:** Disconnect from network if needed
3. **PRESERVE:** Take database snapshot
4. **NOTIFY:** Alert human immediately
5. **INVESTIGATE:** Do NOT restart until root cause found

### Commands

```bash
# E1: Single agent
pm2 stop agent-{code}

# E3: All agents
pm2 stop all

# E5: Force kill
pkill -9 -f claude
```

---

# SECTION 5: QUICK REFERENCE

## 5.1 Domain Quick Lookup

| Domain | Type | Level | Can Import From |
|--------|------|-------|-----------------|
| AUTH | Foundational | 0 | ui, layout, contracts |
| LAYOUT | Foundational | 0 | ui, contracts |
| CORE | Foundational | 0 | contracts |
| CLIENT | Entity | 1 | ui, layout, contracts, auth |
| PILOT | Entity | 1 | ui, layout, contracts, auth |
| PROJECT | Business | 2 | ui, layout, contracts, auth, client, pilot |
| PROPOSAL | Business | 2 | ui, layout, contracts, auth, client, pilot, project |
| PAYMENT | Business | 2 | ui, layout, contracts, auth, client, project, proposal |
| DELIVERABLES | Business | 2 | ui, layout, contracts, auth, client, pilot, project |
| MESSAGING | Support | 3 | All via contracts |
| ADMIN | Support | 3 | All via contracts (read-only) |
| NOTIFICATIONS | Support | 3 | All via contracts |

---

## 5.2 Gate Quick Reference

```
Gate 0: Research     → CTO/PM → Validate approach
Gate 1: Planning     → Dev    → START.md + ROLLBACK-PLAN.md ⚠️
Gate 2: Build        → Dev    → Implement + write tests
Gate 3: Test         → Dev/QA → Pass all tests, coverage ≥80%
Gate 4: QA Review    → QA     → Code quality approved
Gate 5: PM Review    → PM     → Standards met
Gate 6: Integration  → Auto   → CI/CD pass, no conflicts
Gate 7: Deployment   → Human  → Production deploy
```

---

## 5.3 Quick Approval Reference

| Operation | Level | Approver |
|-----------|-------|----------|
| Create file (own domain) | 🟢 L5 | Auto |
| Modify file (own domain) | 🟢 L5 | Auto |
| Create file (shared) | 🟡 L3 | PM |
| Modify file (other domain) | 🚫 L0 | NEVER |
| git commit (feature branch) | 🟢 L5 | Auto |
| git push (feature branch) | 🟢 L5 | Auto |
| git merge to develop | 🟡 L3 | PM |
| git merge to main | 🟠 L2 | CTO |
| Deploy to dev | 🟢 L5 | Auto |
| Deploy to staging | 🟡 L3 | PM |
| Deploy to production | 🔴 L1 | Human |
| npm install (new) | 🔵 L4 | QA |
| npm audit fix | 🟢 L5 | Auto |
| Migration scripts | 🔴 L1 | Human |
| Modify auth code | 🔴 L1 | Human |
| Modify payment code | 🔴 L1 | Human |

---

## 5.4 Stuck Detection Triggers

| Condition | Action |
|-----------|--------|
| Same file modified 5+ times | Pause and reassess |
| Same test failing 3+ times | Escalate to QA |
| No progress 30+ minutes | Request help |
| Token usage > 80% budget | Checkpoint and reduce scope |
| Error loop detected | E1 stop |

---

## 5.5 Files That Require Human Approval

```
src/app/api/auth/**
src/app/api/payment/**
src/lib/auth/**
src/lib/stripe/**
supabase/migrations/*
.env*
package.json (version changes)
docker-compose.yml (production)
```

---

# END OF DOCUMENT

**Version History:**
- V2.1 (2026-01-07): Added Sections 1.8-1.10, E1-E5 levels, Gate 1 templates, signal requirements
- V10.7: Base version with 84 forbidden operations

**Total Forbidden Operations:** 108
**Emergency Levels:** E1, E2, E3, E4, E5
**Gates:** 8 (0-7)
