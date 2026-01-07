# Change Request Protocol: Reuse First, Create Second

**Version:** 1.0  
**Date:** January 7, 2026  
**Purpose:** Ensure Claude always uses existing patterns before creating new implementations

---

## Executive Summary

When you ask Claude to fix a bug, add a feature, or make any change, Claude **MUST**:

1. **Search existing patterns first** → Use if found
2. **Extend existing implementations** → Build on top if found
3. **Check locked patterns** → Cannot contradict
4. **Only then create new** → Document why existing didn't work

This prevents pattern fragmentation, duplicate implementations, and methodology drift.

---

## The Core Problem

### What Goes Wrong Without This Protocol

| Scenario | Bad Outcome | Cost |
|----------|-------------|------|
| "Fix this validation bug" | Claude invents new validation pattern | Now you have 2 validation patterns |
| "Add QA check for X" | Claude creates new QA process | Conflicts with PM Validator |
| "Make agents coordinate better" | Claude proposes websockets | Contradicts locked DB coordination |
| "Improve error handling" | Claude writes new error helper | Duplicates existing error utilities |
| "Add a new gate" | Claude creates parallel gate system | 8-gate system becomes inconsistent |

### What Should Happen

| Request | Correct Response |
|---------|------------------|
| "Fix this validation bug" | Search → Find PM Validator → Fix within that system |
| "Add QA check for X" | Search → Find QA patterns → Extend existing checklist |
| "Make agents coordinate better" | Search → Find DB signals → Improve signal handlers |
| "Improve error handling" | Search → Find error patterns → Add to existing utilities |
| "Add a new gate" | Search → Find 8-gate system → Insert new gate in sequence |

---

## The Protocol: 5-Step Change Process

### Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CHANGE REQUEST RECEIVED                              │
│                    "Fix X" / "Add Y" / "Improve Z"                          │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 1: SEARCH EXISTING                                                     │
│  ─────────────────────                                                       │
│  □ Search project knowledge for related patterns                            │
│  □ Search codebase for related implementations                              │
│  □ Search documentation for related processes                               │
│                                                                              │
│  FOUND? ─────────────────────────┬──────────────────────────────────────────│
│         YES                      │                    NO                     │
│          │                       │                     │                     │
│          ▼                       │                     ▼                     │
│  ┌───────────────┐               │          ┌──────────────────┐            │
│  │ Go to Step 2  │               │          │ Go to Step 4     │            │
│  │ (Check Lock)  │               │          │ (Create New)     │            │
│  └───────────────┘               │          └──────────────────┘            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 2: CHECK IF LOCKED                                                     │
│  ───────────────────────                                                     │
│  □ Check LOCKED-REGISTRY.yaml                                               │
│  □ Check FORBIDDEN-OPERATIONS                                               │
│  □ Check architectural decisions                                            │
│                                                                              │
│  LOCKED? ────────────────────────┬──────────────────────────────────────────│
│          YES                     │                    NO                     │
│           │                      │                     │                     │
│           ▼                      │                     ▼                     │
│  ┌────────────────────┐          │          ┌──────────────────┐            │
│  │ STOP               │          │          │ Go to Step 3     │            │
│  │ Ask human approval │          │          │ (Extend)         │            │
│  │ Cannot modify      │          │          └──────────────────┘            │
│  └────────────────────┘          │                                          │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 3: EXTEND EXISTING                                                     │
│  ───────────────────────                                                     │
│  □ Use existing pattern as foundation                                       │
│  □ Add new functionality ON TOP of existing                                 │
│  □ Do NOT duplicate or replace                                              │
│  □ Document extension in same location                                      │
│                                                                              │
│  POSSIBLE? ──────────────────────┬──────────────────────────────────────────│
│            YES                   │                    NO                     │
│             │                    │                     │                     │
│             ▼                    │                     ▼                     │
│  ┌────────────────────┐          │          ┌──────────────────┐            │
│  │ Implement extension│          │          │ Go to Step 4     │            │
│  │ Go to Step 5       │          │          │ (Create New)     │            │
│  └────────────────────┘          │          └──────────────────┘            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 4: CREATE NEW (Last Resort)                                            │
│  ────────────────────────────────                                            │
│  □ Document WHY existing patterns don't work                                │
│  □ Follow existing code style and conventions                               │
│  □ Reference existing patterns for consistency                              │
│  □ Add to pattern registry for future reuse                                 │
│  □ Propose for locking if validated                                         │
│                                                                              │
│  REQUIREMENTS:                                                               │
│  - Must explain why existing doesn't work                                   │
│  - Must not contradict locked patterns                                      │
│  - Must follow existing conventions                                         │
│  - Must be documented for future reuse                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STEP 5: DOCUMENT OUTCOME                                                    │
│  ────────────────────────                                                    │
│  □ Record what was found                                                    │
│  □ Record what was reused/extended                                          │
│  □ Record any new patterns created                                          │
│  □ Update relevant documentation                                            │
│  □ Propose locking if pattern proves valuable                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Search Existing (MANDATORY)

### What to Search

```markdown
SEARCH CHECKLIST:

□ Project Knowledge (Claude.ai Project)
  - Query: [keywords from request]
  - Look for: Existing patterns, prior decisions, locked items
  
□ Documentation (methodology repo)
  - LOCKED/ directory
  - core/ documentation
  - reference/ documentation
  - learnings/ for past solutions

□ Codebase (if implementation)
  - Similar functions/components
  - Utility files
  - Shared patterns
  - Test files (often show patterns)

□ Past Conversations (if relevant)
  - Prior discussions on same topic
  - Decisions already made
```

### Search Query Patterns

| Request Type | Search Keywords |
|--------------|-----------------|
| Bug fix | error name, component name, feature area |
| New feature | similar feature names, domain keywords |
| Process change | gate, validation, QA, PM, agent |
| Architecture | pattern name, domain name, integration |
| Performance | cache, optimize, async, batch |

### Search Output Template

```markdown
## 🔍 SEARCH RESULTS

**Query:** "[your search terms]"

**Project Knowledge Found:**
- ✅ [filename.md] - [Section]: [brief description]
- ✅ [filename.md] - [Section]: [brief description]
- ❌ No results for [alternative terms]

**Codebase Found:**
- ✅ [filepath] - [function/component]: [what it does]
- ✅ [filepath] - [pattern]: [how it's used]

**Decision:**
- [ ] REUSE: Found exact match → Use as-is
- [ ] EXTEND: Found similar → Build on top
- [ ] CREATE: Nothing found → New implementation needed
```

---

## Step 2: Check If Locked

### Quick Lock Check

```markdown
LOCK CHECK:

□ Is this pattern in LOCKED-REGISTRY.yaml?
  → If YES: Cannot modify without human approval
  
□ Does this contradict FORBIDDEN-OPERATIONS?
  → If YES: Cannot implement
  
□ Does this contradict a locked architectural decision?
  → Git worktree strategy
  → 8-gate system
  → Database coordination
  → Independent QA
  → If YES: Cannot proceed without human approval
  
□ Does this modify core safety protocols?
  → Rollback procedures
  → Error handling patterns
  → If YES: Requires explicit approval
```

### If Locked: Response Template

```markdown
## 🔒 LOCKED PATTERN DETECTED

**Your Request:** [what they asked]

**Locked Pattern Found:** [pattern name]
**Location:** [file/section]
**Reason Locked:** [why it's protected]

**This pattern cannot be modified because:**
[explanation of why it's locked]

**Options:**
1. Work within existing pattern (recommended)
2. Provide approval to unlock (requires justification)
3. Propose alternative that doesn't conflict

**To proceed with modification, please confirm:**
- [ ] You understand this is a locked pattern
- [ ] You have a specific reason to modify it
- [ ] You accept responsibility for testing the change
```

---

## Step 3: Extend Existing (Preferred)

### Extension Principles

```markdown
EXTENSION RULES:

1. ADD, don't REPLACE
   ❌ Rewrite the validation function
   ✅ Add a new check to existing validation

2. AUGMENT, don't DUPLICATE
   ❌ Create a new error handler
   ✅ Extend existing error handler with new case

3. COMPOSE, don't FORK
   ❌ Copy the pattern and modify it
   ✅ Import the pattern and wrap/extend it

4. DOCUMENT, don't ASSUME
   ❌ Add code without updating docs
   ✅ Update docs to reflect extension
```

### Extension Implementation Template

```markdown
## 🔧 EXTENDING EXISTING PATTERN

**Existing Pattern:** [name/location]
**What it does:** [current functionality]

**Extension Needed:** [what to add]
**Why extension (not new):** [justification]

**Implementation Approach:**
1. Import/reference existing: [how]
2. Add new capability: [what]
3. Maintain backward compatibility: [how]
4. Update documentation: [where]

**Files to Modify:**
- [existing-file.ts] - Add [specific addition]
- [existing-docs.md] - Document new capability

**Files NOT to Create:**
- ❌ [new-duplicate.ts] - Would duplicate existing
```

---

## Step 4: Create New (Last Resort)

### When Creating New is Acceptable

```markdown
CREATE NEW ONLY WHEN:

✅ No existing pattern found (documented in Step 1)
✅ Existing pattern cannot be extended (explained why)
✅ Does not contradict locked patterns (verified in Step 2)
✅ Follows existing conventions (style, structure)
✅ Will be documented for future reuse

❌ NEVER CREATE NEW WHEN:
- Similar pattern exists but you don't like it
- Extending existing seems "harder"
- You have a "better idea" that conflicts
- You didn't search thoroughly enough
```

### New Pattern Template

```markdown
## 🆕 NEW PATTERN REQUIRED

**Searched For:** [what you looked for]
**Why Not Found:** [no existing pattern exists because...]
**Why Can't Extend:** [existing patterns don't cover this because...]

**New Pattern:**
- **Name:** [descriptive name]
- **Purpose:** [what problem it solves]
- **Location:** [where it will live]
- **Follows conventions from:** [reference existing pattern for style]

**Documentation Plan:**
- Add to: [which documentation file]
- Future reuse: [how others will find and use this]
- Lock candidate: [yes/no, if yes when]

**Implementation:**
[actual implementation]

**Registration:**
Add to pattern registry:
```yaml
patterns:
  - name: "[pattern name]"
    file: "[location]"
    created: "[date]"
    purpose: "[description]"
    reuse_for: "[future use cases]"
```
```

---

## Step 5: Document Outcome

### After Every Change

```markdown
## 📝 CHANGE DOCUMENTATION

**Request:** [original request]
**Date:** [date]

**Search Performed:**
- Project knowledge: [queries used]
- Codebase: [paths searched]
- Documentation: [files checked]

**Pattern Used:**
- [ ] Reused existing: [pattern name, location]
- [ ] Extended existing: [pattern name, what was added]
- [ ] Created new: [pattern name, justification]

**Files Modified:**
- [file1] - [what changed]
- [file2] - [what changed]

**Documentation Updated:**
- [doc1] - [what was added]

**Future Reuse:**
This solution can be reused for: [similar scenarios]
```

---

## Integration with Claude.ai Project

### Add to Project Instructions

```markdown
# 🔄 CHANGE REQUEST PROTOCOL

When I ask you to fix, add, improve, or change anything:

## MANDATORY FIRST STEP
Before ANY implementation:
1. Search project knowledge for existing patterns
2. Search for related documentation
3. Report what you found

## DECISION TREE
- FOUND exact match → Use it as-is
- FOUND similar → Extend it, don't duplicate
- FOUND locked pattern → Cannot modify without my approval
- FOUND nothing → Create new, but follow existing conventions

## FORBIDDEN
❌ Creating new patterns when existing ones work
❌ Duplicating functionality that exists
❌ Contradicting locked architectural decisions
❌ Implementing without searching first

## REQUIRED
✅ Always search before implementing
✅ Always report search results
✅ Always prefer extension over creation
✅ Always document new patterns for future reuse
```

### Add to Agent CLAUDE.md

```markdown
# ═══════════════════════════════════════════════════════════════
# 🔄 CHANGE REQUEST PROTOCOL - REUSE FIRST
# ═══════════════════════════════════════════════════════════════

Before implementing ANY change:

## Step 1: Search (MANDATORY)
□ Search codebase for similar implementations
□ Search documentation for existing patterns
□ Check LOCKED patterns that cannot be modified

## Step 2: Decide
□ FOUND exact → Use it
□ FOUND similar → Extend it
□ FOUND locked → STOP, signal PM
□ FOUND nothing → Create new (document why)

## Step 3: Implement
□ If extending: Add ON TOP, don't replace
□ If creating new: Follow existing conventions
□ Update documentation

## FORBIDDEN
- Creating duplicate implementations
- Ignoring existing patterns
- Contradicting locked decisions
- Implementing without searching

## Output Template
"I searched for [X] and found [Y]. I will [reuse/extend/create] because [reason]."
```

---

## Quick Reference Card

### For Every Change Request

```
┌────────────────────────────────────────────────────────────────┐
│  CHANGE REQUEST RECEIVED                                        │
│                                                                  │
│  1. SEARCH FIRST                                                │
│     □ Project knowledge                                         │
│     □ Codebase                                                  │
│     □ Documentation                                             │
│                                                                  │
│  2. REPORT FINDINGS                                             │
│     "I found [X] that does [Y]..."                              │
│                                                                  │
│  3. DECIDE APPROACH                                             │
│     □ REUSE: "I'll use existing [pattern]"                      │
│     □ EXTEND: "I'll add to existing [pattern]"                  │
│     □ CREATE: "Nothing exists, I'll create [X] following [Y]"   │
│     □ BLOCKED: "This conflicts with locked [pattern]"           │
│                                                                  │
│  4. IMPLEMENT                                                   │
│     □ Follow existing conventions                               │
│     □ Document changes                                          │
│     □ Register new patterns                                     │
│                                                                  │
│  5. VERIFY                                                      │
│     □ No duplicates created                                     │
│     □ No locked patterns violated                               │
│     □ Documentation updated                                     │
└────────────────────────────────────────────────────────────────┘
```

---

## Examples

### Example 1: Bug Fix Request

**Request:** "Fix the validation that's allowing empty names"

**Correct Response:**
```markdown
## 🔍 SEARCH RESULTS

**Query:** "validation name empty"

**Found:**
- ✅ PM-VALIDATOR-V5.5.md - Section 3.2: Input validation patterns
- ✅ src/lib/validation.ts - validateName(): Current implementation
- ✅ LOCKED: Validation patterns are validated and locked

**Decision:** EXTEND existing validation

**Implementation:**
I'll add an empty string check to the existing validateName() 
function in src/lib/validation.ts, following the pattern already 
used for null checks on line 45.

Files to modify:
- src/lib/validation.ts (add empty check)
- src/lib/validation.test.ts (add test case)
```

### Example 2: New Feature Request

**Request:** "Add a new type of agent notification"

**Correct Response:**
```markdown
## 🔍 SEARCH RESULTS

**Query:** "agent notification signal alert"

**Found:**
- ✅ workflow-3_2-protocol.md - Section 8: Signal system
- ✅ src/signals/agentSignals.ts - Existing notification handlers
- ✅ LOCKED: Database coordination pattern (must use signals table)

**Decision:** EXTEND existing signal system

**Implementation:**
I'll add a new signal type to the existing agentSignals.ts,
following the pattern of PM_REVIEW_NEEDED signal on line 78.

This maintains the locked database coordination pattern while
adding the new notification capability.

Files to modify:
- src/signals/types.ts (add new signal type)
- src/signals/agentSignals.ts (add handler)
- workflow-3_2-protocol.md (document new signal)
```

### Example 3: Architecture Request

**Request:** "Let's use Redis for agent coordination instead of the database"

**Correct Response:**
```markdown
## 🔒 LOCKED PATTERN DETECTED

**Your Request:** Use Redis for agent coordination

**Locked Pattern Found:** Database Coordination
**Location:** LOCKED/architecture/DATABASE-COORDINATION.md
**Locked Since:** 2026-01-05

**This pattern is locked because:**
- Validated through signal flow smoke test
- Provides auditability (full query trail)
- Enables recovery (can replay from database state)

**Options:**
1. ✅ Continue using database coordination (recommended)
2. ⚠️ Add Redis as CACHE layer on top of database coordination
3. 🔓 Provide explicit approval to unlock and replace

**If you want to proceed with replacement:**
- Provide written justification
- Accept testing responsibility
- Confirm approval: "I approve unlocking DATABASE-COORDINATION"
```

---

## Summary

The protocol ensures:

| Principle | Implementation |
|-----------|----------------|
| **Search First** | Mandatory search before any implementation |
| **Reuse Existing** | Use existing patterns when found |
| **Extend Over Create** | Add to existing rather than duplicate |
| **Respect Locks** | Cannot modify locked patterns without approval |
| **Document Everything** | All changes recorded for future reuse |
| **Consistency** | New patterns follow existing conventions |

This prevents pattern fragmentation, reduces duplicate code, maintains consistency, and ensures your validated patterns remain intact.
