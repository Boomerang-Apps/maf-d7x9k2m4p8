# MAF FMEA V11.0.0
## Failure Mode and Effects Analysis

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - /mnt/project/AEROSPACE-GRADE-SAFETY-RECOMMENDATIONS.md (23K, lines 373-395)
  - /mnt/project/COMPLETE-SAFETY-REFERENCE.md (90K)
  
Extraction Method: 
  - FMEA template from aerospace recommendations
  - Expanded with failure modes from test history
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0  
**Classification:** CRITICAL - Risk Analysis  
**Standard:** Based on DO-178C FMEA requirements

---

## What is FMEA?

**Failure Mode and Effects Analysis (FMEA)** is an aerospace-grade risk assessment method that documents:
1. What can fail
2. Effect of each failure
3. Severity of the effect
4. Probability of occurrence
5. Detection method
6. Mitigation strategy
7. Risk Priority Number (RPN)

### RPN Calculation
```
RPN = Severity × Probability × Detection
```
- **Severity (S):** 1-10 (10 = catastrophic)
- **Probability (P):** 1-10 (10 = certain to occur)
- **Detection (D):** 1-10 (10 = undetectable)

**RPN Thresholds:**
- RPN ≤ 50: Acceptable
- RPN 51-100: Monitor closely
- RPN 101-200: Action required
- RPN > 200: Critical - must fix before operation

---

## Multi-Agent System FMEA

| ID | Failure Mode | Effect | S | P | D | RPN | Detection Method | Mitigation | Status |
|----|--------------|--------|---|---|---|-----|------------------|------------|--------|
| **F01** | Agent infinite loop | Cost overrun ($47K example) | 8 | 5 | 3 | 120 | Iteration counter | Hard cap 25 iterations | ✅ Implemented |
| **F02** | Database corruption | Data loss | 10 | 2 | 4 | 80 | Checksum validation | Pre-migration backup | ✅ Implemented |
| **F03** | Credential exposure | Security breach | 10 | 3 | 2 | 60 | Pattern scanning | Forbidden ops list | ✅ Implemented |
| **F04** | Wrong branch merge | Code loss | 7 | 4 | 3 | 84 | Branch protection | Git worktrees | ✅ Implemented |
| **F05** | QA self-approval | Bad code in prod | 8 | 4 | 3 | 96 | Agent ID check | Independent QA agent | ✅ Implemented |
| **F06** | Token budget exceeded | Cost overrun | 6 | 5 | 2 | 60 | Budget tracking | Hard limit enforcement | ✅ Implemented |
| **F07** | Agent stuck (no progress) | Wasted resources | 5 | 6 | 3 | 90 | Progress monitoring | External stuck detection | ✅ Implemented |
| **F08** | Merge conflict | Pipeline blocked | 6 | 4 | 2 | 48 | Git status check | Worktree isolation | ✅ Implemented |
| **F09** | API key exhausted | System halt | 8 | 2 | 2 | 32 | Usage monitoring | Key rotation | ✅ Implemented |
| **F10** | Network failure | Agent isolation | 7 | 3 | 3 | 63 | Health checks | Circuit breaker | ✅ Implemented |
| **F11** | rm -rf execution | Data destruction | 10 | 2 | 1 | 20 | Command parsing | Forbidden ops block | ✅ Implemented |
| **F12** | Force push to main | History loss | 9 | 2 | 1 | 18 | Command parsing | Forbidden ops block | ✅ Implemented |
| **F13** | Secrets in logs | Credential leak | 9 | 3 | 4 | 108 | Log scanning | Forbidden ops block | ✅ Implemented |
| **F14** | Production deploy | User impact | 8 | 2 | 2 | 32 | Environment check | L1 Human approval | ✅ Implemented |
| **F15** | Cross-domain edit | Code conflict | 6 | 4 | 2 | 48 | Domain validation | File ownership rules | ✅ Implemented |
| **F16** | Missing rollback plan | Unrecoverable | 8 | 3 | 2 | 48 | Gate 1 check | ROLLBACK.md required | ✅ Implemented |
| **F17** | Claude CLI asks questions | Pipeline stall | 7 | 8 | 2 | 112 | Output monitoring | --dangerously-skip-permissions | ✅ Implemented |

---

## Detailed Failure Analyses

### F01: Agent Infinite Loop

**Real-World Example:**
> "$47,000 API bill from two agents talking to each other for 11 days" - Tech Startups, Nov 2025

**Failure Chain:**
```
Agent starts → Hits error → Retries → Same error → Retries again → 
→ Loop continues → Tokens consumed → Budget exceeded → Cost overrun
```

**Detection:**
```bash
# merge-watcher.sh
ITERATION_LIMIT=25

if [ "$iteration_count" -gt "$ITERATION_LIMIT" ]; then
    echo "❌ ITERATION LIMIT EXCEEDED"
    docker stop $container_id
fi
```

**Mitigation:**
- Hard cap: 25 iterations per story
- Time limit: 120 minutes per story
- Same-error detection: 3 repeats triggers stop

---

### F05: QA Self-Approval

**Failure Chain:**
```
Dev agent completes code → Same agent runs QA → Approves own code →
→ Bugs not caught → Bad code merges → Production issues
```

**Detection:**
```bash
# Check agent IDs in QA signal
qa_agent=$(jq -r '.from_agent' qa_approved.json)
dev_agent=$(jq -r '.from_agent' gate_2_complete.json)

if [ "$qa_agent" = "$dev_agent" ]; then
    echo "❌ SELF-APPROVAL DETECTED"
    exit 1
fi
```

**Mitigation:**
- Gate 4 must be different agent than Gate 2
- Use different AI model for QA (e.g., Haiku for QA, Sonnet for Dev)
- System validates agent IDs before accepting QA signal

---

### F13: Secrets in Logs

**Failure Chain:**
```
Agent runs command → Output includes secrets → 
→ Logged to file → File persisted → Secret exposed
```

**Detection Patterns:**
```typescript
const SECRET_PATTERNS = [
  /ANTHROPIC_API_KEY=[A-Za-z0-9-]+/,
  /sk-ant-[A-Za-z0-9-]+/,
  /supabase_[a-z]+_key=[A-Za-z0-9-]+/i,
  /password\s*[:=]\s*['"][^'"]+['"]/i
];
```

**Mitigation:**
- Forbidden ops block: `echo $API_KEY`, `cat .env`
- Log sanitization before storage
- Secrets never passed in prompts

---

### F17: Claude CLI Asks Questions (Highest Probability)

**Real Test Failure:** Test 8.6 - 80% failure rate (5/25 containers succeeded)

**Failure Chain:**
```
Claude CLI starts → Prompts "Accept permissions?" → 
→ No human to answer → Container hangs → Pipeline stalls
```

**Root Cause:** Claude CLI designed for interactive use, not autonomous execution.

**Detection:**
```bash
# Check for CLI flags in command
if ! grep -q '\-\-dangerously-skip-permissions' docker-compose.yml; then
    echo "❌ Missing --dangerously-skip-permissions flag"
fi
```

**Mitigation:**
- Always use `--dangerously-skip-permissions` flag
- Always use non-root user (root is blocked)
- Use bulletproof command format: `["bash", "-c", "claude -p '...' --dangerously-skip-permissions"]`

---

## Pre-Flight Checklist (From FMEA)

Before every wave execution, verify these FMEA mitigations are in place:

```markdown
## PRE-FLIGHT CHECKLIST

### Safety Controls
- [ ] Kill switch mechanism exists and tested
- [ ] Stuck detection threshold configured (30 min)
- [ ] Iteration limit set (25 max)
- [ ] Token budget defined per wave

### Execution Controls  
- [ ] All agents use non-root user
- [ ] All agents use --dangerously-skip-permissions
- [ ] All agents have unique IDs (no self-approval)
- [ ] Git worktrees created per agent

### Quality Controls
- [ ] ROLLBACK-PLAN.md required at Gate 1
- [ ] QA agent different from Dev agent
- [ ] PM approval required before merge
- [ ] CTO merge authority enforced

### Detection Controls
- [ ] Forbidden operations list active (108 ops)
- [ ] Secret patterns blocked
- [ ] Domain boundaries validated
- [ ] Circuit breaker configured
```

---

## RPN Priority Matrix

```
                     PROBABILITY
              Low (1-3)  Med (4-6)  High (7-10)
         ┌─────────────┬──────────┬───────────┐
  High   │    F02      │   F05    │    F17    │
  (7-10) │    F03      │   F01    │           │
         │    F14      │   F07    │           │
SEVERITY ├─────────────┼──────────┼───────────┤
  Med    │    F09      │   F04    │           │
  (4-6)  │    F11      │   F08    │           │
         │    F12      │   F15    │           │
         │    F16      │   F10    │           │
         ├─────────────┼──────────┼───────────┤
  Low    │             │          │           │
  (1-3)  │             │          │           │
         └─────────────┴──────────┴───────────┘
```

**Priority Order (by RPN):**
1. F01: Agent infinite loop (RPN 120) ← Action Required
2. F17: CLI asks questions (RPN 112) ← Action Required
3. F13: Secrets in logs (RPN 108) ← Action Required
4. F05: QA self-approval (RPN 96)
5. F07: Agent stuck (RPN 90)
6. F04: Wrong branch merge (RPN 84)
7. F02: Database corruption (RPN 80)

---

## Continuous FMEA Updates

This FMEA document should be updated when:
1. New failure mode discovered in testing
2. Mitigation effectiveness changes
3. New features introduce new failure modes
4. RPN thresholds need adjustment

**Review Frequency:** After every major test execution

---

**Document Status:** LOCKED  
**Last Updated:** 2026-01-08  
**Source:** AEROSPACE-GRADE-SAFETY-RECOMMENDATIONS.md
