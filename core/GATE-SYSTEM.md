# MAF GATE SYSTEM V11.0.0
## 8-Gate Quality Pipeline for Autonomous Agents

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - /mnt/project/WORKFLOW-V4_3-COMPLETE.md (52K)
  - /mnt/project/workflow-3.0-protocol.md (48K)
  - /mnt/project/WORKFLOW-V4_0-COMPLETE.md (63K)
  
Extraction Method: 
  - Combined gate definitions from V3.0 and V4.3
  - Standardized format for V11.0.0
  - NO NEW CONTENT INVENTED
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0  
**Classification:** CORE - Defines quality checkpoints  
**Total Gates:** 8 (0-7)

---

## Gate System Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                         8-GATE QUALITY PIPELINE                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  Gate 0          Gate 1          Gate 2          Gate 3                         │
│  Research        Planning        Implementation  Self-Test                      │
│  ─────────       ────────        ──────────────  ─────────                      │
│  CTO Agent   →   PM Agent    →   Dev Agents  →   Dev Agents                     │
│  ✓ Architecture  ✓ START.md     ✓ Code          ✓ Unit tests                    │
│  ✓ Feasibility   ✓ ROLLBACK.md  ✓ Tests         ✓ Coverage ≥80%                │
│  ✓ Scope         ✓ Branch       ✓ Docs          ✓ Types pass                   │
│                  ✓ Checkpoint                   ✓ Lint pass                    │
│      │               │               │               │                         │
│      ▼               ▼               ▼               ▼                         │
│  ┌───────┐       ┌───────┐       ┌───────┐       ┌───────┐                     │
│  │BLOCKED│       │BLOCKED│       │BLOCKED│       │BLOCKED│                     │
│  │if fail│       │if fail│       │if fail│       │if fail│                     │
│  └───────┘       └───────┘       └───────┘       └───────┘                     │
│                                                                                 │
│  Gate 4          Gate 5          Gate 6          Gate 7                         │
│  QA Review       PM Review       CI/CD           Deployment                     │
│  ─────────       ─────────       ─────           ──────────                     │
│  QA Agent    →   PM Agent    →   Auto/Bash   →   CTO Agent                      │
│  ✓ Full test     ✓ Code review  ✓ Build pass    ✓ Merge to main                │
│  ✓ Coverage      ✓ Standards    ✓ All tests     ✓ Deploy                       │
│  ✓ Security      ✓ Docs         ✓ No conflicts  ✓ Monitor                      │
│  ✗ Self-approval ✓ Acceptance                   ✓ Tag release                  │
│      │               │               │               │                         │
│      ▼               ▼               ▼               ▼                         │
│  ┌───────┐       ┌───────┐       ┌───────┐       ┌───────┐                     │
│  │BLOCKED│       │BLOCKED│       │BLOCKED│       │BLOCKED│                     │
│  │if fail│       │if fail│       │if fail│       │if fail│                     │
│  └───────┘       └───────┘       └───────┘       └───────┘                     │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

# GATE DEFINITIONS

## Gate 0: Research & Architecture

### Owner: CTO Agent

### Purpose
Validate technical feasibility BEFORE any development begins.

### Entry Criteria
- [ ] Story/epic exists with acceptance criteria
- [ ] Domain assigned
- [ ] Dependencies identified

### Required Actions
```
CTO AGENT MUST:
1. Analyze technical feasibility
2. Review architecture implications
3. Identify risks and blockers
4. Validate scope is appropriate
5. Confirm domain assignments
6. Approve for execution
```

### Exit Criteria
- [ ] Architecture decision documented
- [ ] Technical approach approved
- [ ] Risks identified and mitigated
- [ ] Signal: `gate_0_approved`

### Blocking Conditions
```
GATE 0 BLOCKS IF:
- Technical approach not documented
- Risks not identified
- Dependencies not resolved
- Scope unclear
```

---

## Gate 1: Planning & Setup

### Owner: Dev Agent (Assigned)

### Purpose
Create implementation plan and establish rollback capability.

### Entry Criteria
- [ ] Gate 0 complete
- [ ] Story assigned to agent
- [ ] Domain boundaries clear

### Required Actions
```
DEV AGENT MUST:
1. Create START.md with implementation plan
2. Create ROLLBACK-PLAN.md (MANDATORY)
3. Create feature branch: feature/[STORY-ID]-desc
4. Create rollback checkpoint
5. Create gate tag: story/[STORY-ID]/gate-1
```

### START.md Template
```markdown
# START: [STORY-ID]

## Understanding
- What this story accomplishes
- Key acceptance criteria

## Plan
1. Step 1: [action]
2. Step 2: [action]
3. Step 3: [action]

## Files to Create
- [ ] path/to/file1.ts
- [ ] path/to/file2.tsx

## Files to Modify
- [ ] path/to/existing.ts (lines 10-50)

## Tests to Write
- [ ] Unit test for X
- [ ] Integration test for Y

## Estimated Time
- Development: X hours
- Testing: Y hours
```

### ROLLBACK-PLAN.md Template (MANDATORY)
```markdown
# Rollback Plan: [STORY-ID]

## Rollback Trigger Conditions
- [ ] Tests fail after merge
- [ ] Production errors detected
- [ ] Performance degradation
- [ ] Security vulnerability found

## Rollback Steps
1. Revert commit: git revert [commit-sha]
2. [Additional steps specific to this change]

## Data Migration Rollback
[If applicable]

## Notification List
- PM Agent
- CTO Agent (if architectural)
- QA Agent

## Rollback Verification
- [ ] Previous tests pass
- [ ] No regressions
- [ ] Monitoring normal
```

### Exit Criteria
- [ ] START.md exists and complete
- [ ] ROLLBACK-PLAN.md exists (MANDATORY)
- [ ] Feature branch created from main
- [ ] Git tag created: `story/[STORY-ID]/gate-1`
- [ ] Signal: `gate_1_complete`

### Blocking Conditions
```
GATE 1 BLOCKS IF:
- START.md missing or incomplete
- ROLLBACK-PLAN.md missing ← CRITICAL
- Branch not from latest main
- Tag not created
```

---

## Gate 2: Implementation

### Owner: Dev Agent (Assigned)

### Purpose
Write code and tests following TDD approach.

### Entry Criteria
- [ ] Gate 1 complete
- [ ] START.md approved (self-review)
- [ ] TDD approach planned

### Required Actions
```
DEV AGENT MUST:
1. Write tests FIRST (TDD)
2. Implement to pass tests
3. Maintain coverage ≥ 80%
4. Fix ALL TypeScript errors
5. Fix ALL ESLint errors
6. Follow contracts exactly
7. Stay within ownership boundaries
8. Commit frequently with proper messages
```

### Commit Message Format
```
[STORY-ID] type(scope): description

Types:
- feat: New feature
- fix: Bug fix
- test: Adding tests
- refactor: Code refactoring
- docs: Documentation
- chore: Maintenance

Example:
[AUTH-042] feat(login): add password validation

- Add zod schema for password rules
- Add unit tests for validation
- Update LoginForm component
```

### Required Validations (Continuous)
```bash
# Agent MUST run after every significant change:

# 1. TypeScript check
pnpm typecheck
# MUST return: 0 errors

# 2. ESLint check
pnpm lint
# MUST return: 0 errors, 0 warnings

# 3. Test check
pnpm test
# MUST return: All tests passing

# 4. Coverage check
pnpm test:coverage
# MUST return: ≥ 80% coverage on changed files

# 5. Build check
pnpm build
# MUST return: Build successful
```

### Exit Criteria
- [ ] All planned files created
- [ ] All tests written and passing
- [ ] Coverage ≥ 80% on new code
- [ ] Zero TypeScript errors
- [ ] Zero ESLint errors
- [ ] Build successful
- [ ] Signal: `gate_2_complete`

### Blocking Conditions
```
GATE 2 BLOCKS IF:
- Any test failing
- Coverage < 80%
- TypeScript errors exist
- ESLint errors exist
- Build fails
- Files outside ownership modified
- Contracts not followed
```

---

## Gate 3: Self-Validation

### Owner: Dev Agent (Assigned)

### Purpose
Developer validates own work before external QA.

### Entry Criteria
- [ ] Gate 2 complete
- [ ] All validations passing

### Required Actions
```
DEV AGENT MUST:
1. Run FULL validation suite
2. Create validation report
3. Self-review all changes
4. Create git tag: story/[STORY-ID]/gate-3
5. Create signal for QA
```

### Validation Suite
```bash
#!/bin/bash
# Gate 3 Self-Validation

echo "Running Gate 3 Self-Validation..."

# All must pass
pnpm typecheck || exit 1
pnpm lint || exit 1
pnpm test || exit 1
pnpm build || exit 1

# Coverage check
COVERAGE=$(pnpm test:coverage --json | jq '.total.lines.pct')
if (( $(echo "$COVERAGE < 80" | bc -l) )); then
  echo "Coverage $COVERAGE% < 80% - FAILED"
  exit 1
fi

echo "Gate 3 Self-Validation PASSED"
```

### Exit Criteria
- [ ] All validations pass
- [ ] Git tag created: `story/[STORY-ID]/gate-3`
- [ ] Signal: `ready_for_qa` sent to QA agent

### Blocking Conditions
```
GATE 3 BLOCKS IF:
- Any validation fails
- Tag not created
- Signal not sent
```

---

## Gate 4: QA Review

### Owner: QA Agent (Different from Dev)

### Purpose
Independent quality validation by separate agent.

### Entry Criteria
- [ ] Gate 3 complete
- [ ] `ready_for_qa` signal received
- [ ] QA agent is DIFFERENT from dev agent

### Required Actions
```
QA AGENT MUST:
1. Pull latest from feature branch
2. Run full test suite independently
3. Review code changes
4. Verify acceptance criteria met
5. Check for security issues
6. Verify API contract compliance
7. Create QA report
8. Send approval OR rejection signal
```

### QA Checklist
```markdown
## QA Review: [STORY-ID]

### Automated Checks
- [ ] All tests pass
- [ ] Coverage ≥ 80%
- [ ] TypeScript: 0 errors
- [ ] ESLint: 0 errors/warnings
- [ ] Build succeeds

### Manual Checks
- [ ] Acceptance criteria 1: [VERIFIED/FAILED]
- [ ] Acceptance criteria 2: [VERIFIED/FAILED]
- [ ] Acceptance criteria N: [VERIFIED/FAILED]

### Security Checks
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Auth checks in place

### Contract Compliance
- [ ] API matches contract
- [ ] Types match contract
- [ ] No breaking changes

### Verdict
- [ ] APPROVED
- [ ] REJECTED (with reasons)
```

### Critical Rule: NO SELF-APPROVAL
```
❌ FORBIDDEN: QA Agent = Dev Agent (same story)
✅ REQUIRED: QA Agent ≠ Dev Agent
```

### Exit Criteria
- [ ] QA report created
- [ ] Signal: `qa_approved` OR `qa_rejected`

### Blocking Conditions
```
GATE 4 BLOCKS IF:
- Any test fails
- Coverage < 80%
- Security issues found
- Contract mismatch
- Self-approval attempted
```

---

## Gate 5: PM Review

### Owner: PM Agent

### Purpose
Final quality and standards review before CI/CD.

### Entry Criteria
- [ ] Gate 4 complete (QA approved)
- [ ] `qa_approved` signal received

### Required Actions
```
PM AGENT MUST:
1. Review code quality
2. Verify standards compliance
3. Check documentation
4. Verify acceptance criteria
5. Approve for CI/CD
```

### Exit Criteria
- [ ] PM approval documented
- [ ] Signal: `pm_approved`

### Blocking Conditions
```
GATE 5 BLOCKS IF:
- Code quality issues
- Standards violations
- Missing documentation
- Incomplete acceptance criteria
```

---

## Gate 6: CI/CD

### Owner: Automated (merge-watcher.sh)

### Purpose
Automated build and integration verification.

### Entry Criteria
- [ ] Gate 5 complete (PM approved)
- [ ] `pm_approved` signal received

### Required Actions
```
AUTOMATED SYSTEM MUST:
1. Run full build pipeline
2. Run all tests (unit, integration)
3. Check for merge conflicts
4. Verify branch is up-to-date
5. Generate build artifacts
```

### CI/CD Checks
```bash
#!/bin/bash
# Gate 6 CI/CD Validation

# Pull latest
git fetch origin main
git merge origin/main --no-edit || exit 1

# Full validation
pnpm install --frozen-lockfile || exit 1
pnpm typecheck || exit 1
pnpm lint || exit 1
pnpm test || exit 1
pnpm build || exit 1

echo "Gate 6 CI/CD PASSED"
```

### Exit Criteria
- [ ] Build passes
- [ ] All tests pass
- [ ] No merge conflicts
- [ ] Signal: `ci_passed`

### Blocking Conditions
```
GATE 6 BLOCKS IF:
- Build fails
- Tests fail
- Merge conflicts exist
- Dependencies outdated
```

---

## Gate 7: Deployment

### Owner: CTO Agent (Merge Authority)

### Purpose
Final merge and deployment to production.

### Entry Criteria
- [ ] Gate 6 complete (CI passed)
- [ ] `ci_passed` signal received

### Required Actions
```
CTO AGENT MUST:
1. Final verification of all gates
2. Merge to main branch
3. Create release tag
4. Deploy to production
5. Monitor for issues
6. Send completion notification
```

### Merge Commit Format
```
merge: [STORY-ID] - [Title]

Gates Passed:
- Gate 0: ✅ Architecture approved
- Gate 1: ✅ Planning complete
- Gate 2: ✅ Implementation complete
- Gate 3: ✅ Self-test passed
- Gate 4: ✅ QA approved
- Gate 5: ✅ PM approved
- Gate 6: ✅ CI passed

Approved-by: QA-Agent
Reviewed-by: PM-Agent
Merged-by: CTO-Agent
```

### Exit Criteria
- [ ] Merged to main
- [ ] Release tag created: `story/[STORY-ID]/complete`
- [ ] Deployed successfully
- [ ] Monitoring shows healthy
- [ ] Signal: `story_complete`

### Blocking Conditions
```
GATE 7 BLOCKS IF:
- Any previous gate failed
- Merge conflicts
- Deployment fails
- Monitoring shows errors
```

---

# GATE ENFORCEMENT

## Signal Types

| Signal | Created By | Consumed By | Purpose |
|--------|------------|-------------|---------|
| `gate_0_approved` | CTO | PM | Architecture OK |
| `gate_1_complete` | Dev | Dev (self) | Planning done |
| `gate_2_complete` | Dev | Dev (self) | Code done |
| `ready_for_qa` | Dev | QA | Request review |
| `qa_approved` | QA | PM | QA passed |
| `qa_rejected` | QA | Dev | QA failed |
| `pm_approved` | PM | CI | PM passed |
| `ci_passed` | Auto | CTO | CI passed |
| `story_complete` | CTO | All | Done |

## Gate Skip Prevention

```
❌ FORBIDDEN:
- Skip any gate
- Self-approve QA (Gate 4)
- Merge without PM approval (Gate 5)
- Deploy without CI pass (Gate 6)
- Push directly to main (bypasses Gate 7)
```

---

# QUICK REFERENCE

| Gate | Owner | Key Deliverable | Blocker |
|------|-------|-----------------|---------|
| 0 | CTO | Architecture approved | Unclear scope |
| 1 | Dev | START.md + ROLLBACK.md | Missing rollback plan |
| 2 | Dev | Working code + tests | Test failure |
| 3 | Dev | Self-validation pass | Coverage < 80% |
| 4 | QA | Independent approval | Self-approval |
| 5 | PM | Standards compliance | Quality issues |
| 6 | Auto | CI/CD pass | Build failure |
| 7 | CTO | Merged + deployed | Merge conflict |

---

**Document Status:** LOCKED  
**Last Updated:** 2026-01-08  
**Source:** WORKFLOW-V4_3-COMPLETE.md, workflow-3.0-protocol.md
