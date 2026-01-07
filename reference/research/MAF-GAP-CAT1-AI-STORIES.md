# MAF Gap Analysis: Category 1 - AI Stories

**Date:** January 7, 2026  
**Category:** AI Stories  
**Priority:** P0 (Critical)  
**Status:** Gap Analysis Complete

---

# EXECUTIVE SUMMARY

## Sources Analyzed

| Source | Version | Size | Purpose |
|--------|---------|------|---------|
| ai-story-schema-v3.json | V10.7 | 11KB | Current canonical schema |
| ai-story.schema.json | AI Stories V1 | 10KB | Alternative schema |
| index.ts | Linter V1 | 28KB | TypeScript validation |
| AI-STORY-TEMPLATES-IMPLEMENTATION.md | - | 14KB | Templates |
| AI-STORY-EPIC-CREATION-GUIDE.md | - | 48KB | Epic breakdown |

## Gap Summary

| Aspect | V10.7 Status | Gap Level |
|--------|--------------|-----------|
| Schema Structure | ⚠️ Partial | Medium - Missing 12 fields |
| Validation | ⚠️ Partial | High - Missing linter checks |
| EARS Notation | ✅ Good | Low - Need threshold enforcement |
| Traceability | ✅ Excellent | None - V10.7 is best |
| Safety | ⚠️ Partial | Medium - Need per-story stop_conditions |

---

# FIELD-BY-FIELD GAP ANALYSIS

## ✅ KEEP FROM V10.7 (No Changes)

| Field | V10.7 Implementation | Reason |
|-------|---------------------|--------|
| `traceability` | Full object with requirement_source, verification_method | Unique aerospace feature |
| `safety_classification.dal_level` | A/B/C/D/E enum | DO-178C compliance |
| `safety_classification.requires_human_approval` | Boolean | Critical safety gate |
| `actual_hours`, `actual_tokens`, `actual_cost` | Number fields | Tracking metrics |
| `gate`, `status` | Integer 0-7, enum | Workflow tracking |
| AC traceability fields | implementation_file, test_file, coverage | Code-to-requirement mapping |

## ❌ ADD FROM AI STORIES V1 (Missing)

### Priority 1: Critical (Must Add)

| Field | Specification | Reason |
|-------|---------------|--------|
| **Title Action Verb** | Pattern: `^(Create\|Add\|Update\|Fix\|Remove\|Implement\|...)` | Quality enforcement |
| **files.forbidden** | Required array, minItems: 1 | Domain isolation |
| **stop_conditions** | Required array, minItems: 3 | Per-story safety |
| **Min 3 Acceptance Criteria** | minItems: 3 | Quality threshold |

### Priority 2: Important (Should Add)

| Field | Specification | Reason |
|-------|---------------|--------|
| **objective** | Object: as_a, i_want, so_that (all required) | User story clarity |
| **scope** | Object: in_scope, out_of_scope, definitions | Prevent scope creep |
| **complexity** | Enum: S/M/L/XL with hour mapping | Estimation |
| **api_contract** | Object: endpoint, request, response | BE story specification |
| **tests** | Object: commands, coverage_threshold, unit_tests | Test specification |
| **agent** | Pattern: `^[a-z]+-[a-z]+-[a-z]+$` | Agent assignment validation |

### Priority 3: Nice to Have

| Field | Specification | Reason |
|-------|---------------|--------|
| **implementation_hints** | Array of strings | Agent guidance |
| **rollback_plan** | Object: git_strategy, database_rollback, recovery_steps | Recovery planning |
| **definition_of_done** | Array of checklist items | Completion criteria |

## ⚠️ STANDARDIZE (Different Formats)

| Field | V10.7 | AI Stories V1 | Decision |
|-------|-------|---------------|----------|
| **ID Pattern** | `WAVE#-TYPE-###` | `DOMAIN-TYPE-###` | Support BOTH |
| **Priority** | `critical/high/medium/low` | `P0-Critical/P1-High/...` | Use V1 (more explicit) |
| **Domain Enum** | 6 technical | 12 business | Use V1 business domains |

---

# VALIDATION GAP ANALYSIS

## Current PM Validator Coverage

The PM Validator v5.7.sh has 104 checks across sections A-Q, but **lacks story-specific validation**.

## Missing Validation Checks

### From AI Stories V1 Linter (Must Add)

| Check | Code | Description |
|-------|------|-------------|
| Action Verb Title | `MISSING_ACTION_VERB` | Title must start with verb |
| Minimum AC Count | `INSUFFICIENT_AC` | At least 3 acceptance criteria |
| EARS Keywords | `MISSING_EARS` | SHALL/WHEN/IF/THEN required |
| Measurability | `UNMEASURABLE_CRITERION` | Threshold must be quantifiable |
| Forbidden Files | `MISSING_FORBIDDEN` | files.forbidden required |
| Stop Conditions | `MISSING_STOP_CONDITIONS` | At least 3 stop conditions |
| Domain Valid | `INVALID_DOMAIN` | Must be in 12-domain enum |
| Agent Pattern | `INVALID_AGENT` | Must match domain-type-role |

### Measurability Patterns (15 Regex)

```typescript
const MEASURABILITY_PATTERNS = [
  /within \d+\s*(ms|s|seconds|milliseconds|minutes)/i,
  /[<>≤≥]=?\s*\d+/,
  /return\s+\d{3}/i,
  /status\s*:?\s*\d{3}/i,
  /display\s*["'][^"']+["']/i,
  /maximum\s+\d+/i,
  /minimum\s+\d+/i,
  /\d+%/,
  /\d+\s*(items?|records?|rows?)/i,
  /at\s+least\s+\d+/i,
  /at\s+most\s+\d+/i,
  /\d+\s*(attempts?|retries?)/i,
  /\d+\s*(chars?|characters)/i,
  /expire[sd]?\s+(in\s+)?\d+/i,
  /\d+h\s+expiry/i,
];
```

### Anti-Pattern Detection (8 Patterns)

| Pattern | Suggestion |
|---------|------------|
| `make it fast` | Use "within 200ms" |
| `handle errors` | Use "return 400 with {code, message}" |
| `update the database` | Specify table and operation |
| `use best practices` | Reference specific pattern |
| `good test coverage` | Use "≥80% coverage" |
| `should be secure` | Specify: bcrypt, no plaintext |
| `improve performance` | Use "reduce to <500ms" |
| `properly validate` | Specify validation rules |

### Score System (Missing)

```typescript
function calculateScore(story: Story, errors: LintError[]): number {
  let score = 100;
  
  errors.forEach(e => {
    if (e.severity === 'error') score -= 20;
    if (e.severity === 'warning') score -= 5;
  });
  
  // Bonus for completeness
  if (story.scope) score += 5;
  if (story.api_contract) score += 5;
  if (story.rollback_plan) score += 5;
  
  return Math.max(0, Math.min(100, score));
}

// Thresholds:
// 🟢 95-100: Ready for execution
// 🟡 80-94: Minor fixes needed
// 🟠 60-79: Significant gaps
// 🔴 0-59: Not ready
```

---

# EXECUTION PLAN

## Task 1: Create Merged Schema V4 (2 hours)

**File:** `ai-story-schema-v4.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://maf.dev/schemas/ai-story.v4.json",
  "title": "MAF AI Story Schema V4",
  "version": "4.0.0",
  
  "required": [
    "id", "title", "domain", "objective", 
    "acceptance_criteria", "files", "safety"
  ],
  
  "properties": {
    // All merged fields...
  }
}
```

**Includes:**
- All V10.7 traceability fields
- All V1 quality enforcement fields
- Standardized formats
- Both ID patterns supported

## Task 2: Add PM Validator Section R (1 hour)

**Add to pm-validator-v5.7.sh:**

```bash
# ═══════════════════════════════════════════════════════════════════
# SECTION R: AI STORY QUALITY (R1-R12)
# ═══════════════════════════════════════════════════════════════════

check_R1_action_verb_titles()
check_R2_files_forbidden_required()
check_R3_min_3_acceptance_criteria()
check_R4_measurable_thresholds()
check_R5_no_anti_patterns()
check_R6_stop_conditions_required()
check_R7_average_score_above_95()
check_R8_valid_domain_enum()
check_R9_valid_agent_pattern()
check_R10_ears_keywords_present()
check_R11_dependencies_exist()
check_R12_objective_structured()
```

## Task 3: Create Story Linter TypeScript (2 hours)

**File:** `tools/story-linter.ts`

Port from AI Stories V1 index.ts with additions:
- V4 schema validation
- Score system
- Anti-pattern detection
- Measurability check
- JSON and console output
- CI/CD exit codes

## Task 4: Update EARS Reference (30 min)

**File:** `docs/EARS-REFERENCE.md`

Document:
- 4 EARS patterns (ubiquitous, event-driven, state-driven, unwanted)
- Keywords (SHALL, SHOULD, MAY, WHEN, WHILE, IF, THEN)
- Measurability requirements
- Examples for each pattern

## Task 5: Create Example Stories (1 hour)

**Files:**
- `examples/frontend-story.json` - UI component
- `examples/backend-story.json` - API endpoint
- `examples/database-story.json` - Schema migration
- `examples/qa-story.json` - Test automation

## Task 6: Update Story Templates (30 min)

**File:** `templates/story-template.json`

Fillable template with all V4 fields and inline guidance.

---

# FINAL DELIVERABLE SPECIFICATION

## ai-story-schema-v4.json

**Required Fields (7):**
1. id - DOMAIN-TYPE-### or WAVE#-TYPE-###
2. title - Action verb required
3. domain - 12 business domain enum
4. objective - as_a, i_want, so_that
5. acceptance_criteria - Min 3, EARS format
6. files - create, modify, forbidden (required)
7. safety - stop_conditions (min 3)

**Recommended Fields (8):**
1. agent - domain-type-role pattern
2. priority - P0-P3 format
3. complexity - S/M/L/XL
4. wave - Integer
5. scope - in_scope, out_of_scope
6. api_contract - For BE stories
7. tests - commands, coverage
8. dependencies - stories, contracts, infrastructure

**Tracking Fields (6 - from V10.7):**
1. traceability - requirement_source, verification_method
2. safety_classification - dal_level, requires_human_approval
3. status - backlog through completed
4. gate - 0-7
5. actual_hours, actual_tokens, actual_cost
6. AC traceability - implementation_file, test_file, coverage

---

# VALIDATION CHECKLIST

Before declaring Category 1 complete:

- [ ] ai-story-schema-v4.json created
- [ ] Schema validates with JSON Schema tools
- [ ] PM Validator Section R added (12 checks)
- [ ] Story linter TypeScript created
- [ ] EARS-REFERENCE.md documented
- [ ] 4 example stories created
- [ ] Story template updated
- [ ] All 14 topic gaps addressed
- [ ] Score system implemented
- [ ] Anti-pattern detection working
- [ ] Measurability validation working

---

# ESTIMATED EFFORT

| Task | Hours |
|------|-------|
| Merged Schema V4 | 2.0 |
| PM Validator Section R | 1.0 |
| Story Linter TypeScript | 2.0 |
| EARS Reference | 0.5 |
| Example Stories | 1.0 |
| Story Templates | 0.5 |
| **Total** | **7.0 hours** |

---

**Category 1: AI Stories - Gap Analysis Complete**

**Next:** Category 2: Safety Protocol
