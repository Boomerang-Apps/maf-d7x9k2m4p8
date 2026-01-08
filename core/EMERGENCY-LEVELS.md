# MAF EMERGENCY LEVELS V11.0.0
## E1-E5 Emergency Stop Procedures

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - /mnt/project/COMPLETE-SAFETY-REFERENCE.md (90K, lines 367-600)
  
Extraction Method: 
  - Copied emergency stop procedures from PART 3
  - Reformatted for V11.0.0 structure
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0  
**Classification:** CRITICAL - Emergency procedures

---

## Emergency Level Overview

| Level | Name | Trigger | Scope | Recovery |
|-------|------|---------|-------|----------|
| **E1** | Agent Stop | Single agent issue | One agent | Restart agent |
| **E2** | Domain Stop | Domain-wide issue | All agents in domain | Restart domain |
| **E3** | Wave Stop | Wave-wide issue | All agents in wave | Restart wave |
| **E4** | System Stop | Critical failure | All agents | Human restart |
| **E5** | Emergency Halt | Security breach | Entire system | Incident response |

---

## E1: Single Agent Stop

### Trigger Conditions
- Max iterations (>25) exceeded
- Same error repeated 3+ times
- Token budget exceeded
- Memory > 4GB
- Crash loop (3+ restarts in 15 min)

### Procedure

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         E1: SINGLE AGENT STOP                                   │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  STEP 1: DETECT                                          [Auto: Watchdog]       │
│  • Watchdog detects stuck condition                                             │
│  • Alert created in database                                                    │
│  • Slack notification sent                                                      │
│                                                                                 │
│  STEP 2: CHECKPOINT                                      [Auto: Immediate]      │
│  • Create git tag: checkpoint-{agent}-{timestamp}                               │
│  • Save session state to database                                               │
│  • Record files changed                                                         │
│                                                                                 │
│  STEP 3: STOP                                            [Auto: System]         │
│  • Stop agent process                                                           │
│  • Update session status = 'stopped'                                            │
│  • Log stop reason                                                              │
│                                                                                 │
│  STEP 4: NOTIFY                                          [Auto: Slack]          │
│  • Send alert to #maf-alerts                                                    │
│  • Include: agent, story, reason, duration                                      │
│  • Link to dashboard                                                            │
│                                                                                 │
│  STEP 5: RECOVER                                         [Manual/Auto]          │
│  • Option A: Auto-restart after 15 min (if timeout)                             │
│  • Option B: Human reviews and restarts                                         │
│  • Option C: Reassign story to different agent                                  │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Commands
```bash
# Stop single agent (Docker)
docker stop agent-fe-auth

# Stop single agent (PM2)
pm2 stop agent-fe-auth

# View agent logs before stop
docker logs agent-fe-auth --tail 200

# Create checkpoint
git tag -a "emergency-stop-fe-auth-$(date +%s)" -m "Emergency stop"

# Restart after review
docker start agent-fe-auth
```

---

## E2: Domain Stop

### Trigger Conditions
- Multiple agents in domain stuck (>2)
- Domain budget exceeded
- Cross-agent conflict detected
- Domain tests failing systemically

### Procedure

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         E2: DOMAIN STOP                                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  STEP 1: IDENTIFY                                        [Auto: Watchdog]       │
│  • Detect domain-wide pattern                                                   │
│  • List all affected agents                                                     │
│  • Assess impact                                                                │
│                                                                                 │
│  STEP 2: CHECKPOINT ALL                                  [Auto: System]         │
│  • Create checkpoints for all domain agents                                     │
│  • Tag: domain-stop-{domain}-{timestamp}                                        │
│  • Save all session states                                                      │
│                                                                                 │
│  STEP 3: STOP DOMAIN                                     [Auto: System]         │
│  • Stop all agents in domain                                                    │
│  • Update all session statuses                                                  │
│  • Preserve work in progress                                                    │
│                                                                                 │
│  STEP 4: NOTIFY                                          [Auto: Slack]          │
│  • Alert to #maf-critical                                                       │
│  • Include: domain, agent count, stories affected                               │
│  • Escalate to PM                                                               │
│                                                                                 │
│  STEP 5: DIAGNOSE                                        [Manual: PM]           │
│  • Review logs from all agents                                                  │
│  • Identify root cause                                                          │
│  • Plan recovery                                                                │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Commands
```bash
# Stop all agents in domain
docker stop $(docker ps -q --filter "name=auth-")

# Create domain checkpoint
git tag -a "domain-stop-auth-$(date +%s)" -m "Domain stop: auth"

# View all domain logs
docker logs --tail 100 auth-fe-dev
docker logs --tail 100 auth-be-dev
docker logs --tail 100 auth-qa
```

---

## E3: Wave Stop

### Trigger Conditions
- Budget exceeded (>$100 daily)
- Multiple agents stuck (>3 across domains)
- Wave no progress for 60+ minutes
- Critical error pattern detected

### Procedure

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           E3: WAVE STOP                                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  STEP 1: ALERT                                           [Auto: Watchdog]       │
│  • Critical alert to #maf-critical                                              │
│  • SMS to on-call (if configured)                                               │
│  • Dashboard banner                                                             │
│                                                                                 │
│  STEP 2: CHECKPOINT ALL                                  [Auto: System]         │
│  • Create checkpoints for all running agents                                    │
│  • Tag: wave-stop-{wave_id}-{timestamp}                                         │
│  • Export wave state to JSON                                                    │
│                                                                                 │
│  STEP 3: STOP ALL AGENTS                                 [Auto: System]         │
│  • Stop all agents in wave                                                      │
│  • Update all sessions status = 'stopped'                                       │
│  • Update wave status = 'stopped'                                               │
│                                                                                 │
│  STEP 4: PRESERVE STATE                                  [Auto: DB]             │
│  • Commit all pending changes                                                   │
│  • Push all feature branches                                                    │
│  • Export database state                                                        │
│                                                                                 │
│  STEP 5: HUMAN REVIEW                                    [Manual: Human]        │
│  • Review what happened                                                         │
│  • Decide: Resume / Rollback / Restart                                          │
│  • Fix root cause before resuming                                               │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Commands
```bash
# Emergency stop all agents
docker compose down

# Verify all stopped
docker ps

# Create system checkpoint
git tag -a "wave-emergency-$(date +%s)" -m "Emergency wave stop"

# Export state
pg_dump $DATABASE_URL > backup-$(date +%s).sql
```

---

## E4: System Stop

### Trigger Conditions
- Critical infrastructure failure
- Database connection lost
- API keys exhausted
- System-wide resource exhaustion

### Procedure

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         E4: SYSTEM STOP                                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  STEP 1: IMMEDIATE HALT                                  [Auto: Immediate]      │
│  • Kill all agent processes                                                     │
│  • Halt all automated systems                                                   │
│  • Preserve all state                                                           │
│                                                                                 │
│  STEP 2: CRITICAL ALERT                                  [Auto: Multi-channel]  │
│  • Slack: #maf-critical + @channel                                              │
│  • SMS to human owner                                                           │
│  • Email to team                                                                │
│                                                                                 │
│  STEP 3: STATE PRESERVATION                              [Auto: System]         │
│  • Full database backup                                                         │
│  • Git state snapshot                                                           │
│  • Log export                                                                   │
│                                                                                 │
│  STEP 4: HUMAN INTERVENTION                              [Manual: REQUIRED]     │
│  • Diagnose root cause                                                          │
│  • Fix infrastructure issue                                                     │
│  • Verify system health                                                         │
│                                                                                 │
│  STEP 5: GRADUAL RESTART                                 [Manual: Human]        │
│  • Start one agent at a time                                                    │
│  • Monitor for issues                                                           │
│  • Resume full operation                                                        │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Commands
```bash
# Kill all agent processes
docker compose kill
pkill -f "claude"

# Full backup
pg_dump $DATABASE_URL > emergency-backup-$(date +%s).sql

# Verify nothing running
docker ps
ps aux | grep claude
```

---

## E5: Emergency Halt (Security Breach)

### Trigger Conditions
- Unauthorized merge detected
- Credentials exposed
- Malicious code detected
- Data exfiltration attempt
- Forbidden operation executed

### Procedure

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    E5: EMERGENCY HALT - SECURITY BREACH                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ⚠️  THIS IS A CRITICAL SECURITY INCIDENT                                       │
│                                                                                 │
│  STEP 1: IMMEDIATE HALT                                  [Auto: 0 seconds]      │
│  • Kill all agent processes immediately                                         │
│  • Revoke all API keys                                                          │
│  • Block all external network access                                            │
│  • Lock all repositories                                                        │
│                                                                                 │
│  STEP 2: ALERT                                           [Auto: Immediate]      │
│  • SMS to human owner                                                           │
│  • Email to security                                                            │
│  • Slack to #maf-critical                                                       │
│  • Log incident ID                                                              │
│                                                                                 │
│  STEP 3: ISOLATE                                         [Auto: Immediate]      │
│  • Disconnect affected VMs from network                                         │
│  • Snapshot affected systems                                                    │
│  • Preserve all logs                                                            │
│  • Do NOT delete anything                                                       │
│                                                                                 │
│  STEP 4: ASSESS                                          [Manual: Human]        │
│  • What was compromised?                                                        │
│  • What data was accessed?                                                      │
│  • Was anything exfiltrated?                                                    │
│  • What is the blast radius?                                                    │
│                                                                                 │
│  STEP 5: CONTAIN                                         [Manual: Human]        │
│  • Rotate all credentials                                                       │
│  • Revert unauthorized changes                                                  │
│  • Patch vulnerability                                                          │
│  • Update security rules                                                        │
│                                                                                 │
│  STEP 6: RECOVER                                         [Manual: Human]        │
│  • Verify system integrity                                                      │
│  • Restore from known-good backup                                               │
│  • Gradual service restoration                                                  │
│  • Monitor for recurrence                                                       │
│                                                                                 │
│  STEP 7: POST-INCIDENT                                   [Manual: Human]        │
│  • Write incident report                                                        │
│  • Conduct root cause analysis                                                  │
│  • Update safety procedures                                                     │
│  • Implement preventive measures                                                │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Commands
```bash
# IMMEDIATE HALT
pkill -9 -f "claude"
docker compose kill

# Revoke API keys (rotate after incident)
# [Manual: Go to Anthropic dashboard]

# Snapshot VMs
doctl compute droplet-action snapshot [droplet-id]

# Lock repositories
gh repo edit --enable-branch-protection main

# Isolate network
iptables -A OUTPUT -j DROP
```

---

## Quick Reference

| Level | Scope | Auto? | Human Required? |
|-------|-------|-------|-----------------|
| E1 | One agent | ✅ Yes | Optional |
| E2 | One domain | ✅ Yes | PM review |
| E3 | One wave | ✅ Yes | Human decision |
| E4 | All agents | Partial | ✅ Required |
| E5 | Entire system | Immediate | ✅ Required |

---

## Escalation Path

```
E1 (Agent) ──[3 agents stuck]──> E2 (Domain)
     │
     └──[budget exceeded]──> E3 (Wave)
                                │
                                └──[infra failure]──> E4 (System)
                                                          │
                                                          └──[security breach]──> E5 (Halt)
```

---

**Document Status:** LOCKED  
**Last Updated:** 2026-01-08  
**Source:** COMPLETE-SAFETY-REFERENCE.md
