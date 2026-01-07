# BENCHMARK REPORT: Gap 4 - ai-story-schema-v4.json

**Date:** January 7, 2026  
**Task:** Create merged ai-story-schema-v4.json from V10.7 + AI Stories V1  
**Status:** ✅ COMPLETE

---

## Source Verification

| Source File | Location | Read Status |
|-------------|----------|-------------|
| ai-story_schema.json | /mnt/project/ | ✅ Read completely (355 lines) |
| index.ts (linter) | /mnt/project/ | ✅ Read for measurability patterns |

**Key Content Extracted:**
- All AI Stories V1 fields
- Measurability patterns from linter
- EARS keywords
- Action verb patterns
- Domain list

---

## Requirements Checklist

### Fields From AI Stories V1 (Required)

| # | Field | Status | Evidence |
|---|-------|--------|----------|
| 1 | id (with pattern) | ✅ PASS | Pattern: `^[A-Z]+-[A-Z]+-[0-9]{3}$` |
| 2 | title (action verb pattern) | ✅ PASS | Pattern includes all 16 action verbs |
| 3 | domain (12 business domains) | ✅ PASS | Enum with 12 domains |
| 4 | files.forbidden (required) | ✅ PASS | Required in files object, minItems: 1 |
| 5 | files.create | ✅ PASS | With path pattern validation |
| 6 | files.modify | ✅ PASS | Included |
| 7 | objective (as_a, i_want, so_that) | ✅ PASS | All 3 fields required in object |
| 8 | scope (in_scope, out_of_scope) | ✅ PASS | Both fields required |
| 9 | complexity (S/M/L/XL) | ✅ PASS | Enum with time estimates in description |
| 10 | api_contract | ✅ PASS | Full endpoint, request, response structure |
| 11 | tests (commands, coverage_threshold) | ✅ PASS | Commands required, coverage default 80 |
| 12 | safety.stop_conditions (minItems: 3) | ✅ PASS | Required with minItems: 3 |
| 13 | acceptance_criteria (minItems: 3) | ✅ PASS | EARS format with then pattern |

**AI Stories V1 Coverage: 13/13 (100%)**

---

### Fields From V10.7 (Traceability)

| # | Field | Status | Evidence |
|---|-------|--------|----------|
| 1 | traceability.epic_id | ✅ PASS | Pattern: `^EPIC-[0-9]+$` |
| 2 | traceability.feature_id | ✅ PASS | Included |
| 3 | traceability.linear_id | ✅ PASS | Included |
| 4 | traceability.created_at | ✅ PASS | format: date-time |
| 5 | traceability.created_by | ✅ PASS | Included |
| 6 | traceability.approved_by | ✅ PASS | Included |
| 7 | traceability.approved_at | ✅ PASS | format: date-time |
| 8 | execution.status | ✅ PASS | 9-value enum |
| 9 | execution.current_gate | ✅ PASS | 0-7 for 8-gate system |
| 10 | execution.assigned_agent | ✅ PASS | Included |
| 11 | execution.branch_name | ✅ PASS | Pattern matches story ID |
| 12 | execution.worktree_path | ✅ PASS | Included |
| 13 | metrics.tokens_used | ✅ PASS | Included |
| 14 | metrics.iterations | ✅ PASS | Included |
| 15 | metrics.test_coverage | ✅ PASS | 0-100 range |
| 16 | metrics.quality_score | ✅ PASS | 0-100 range |

**V10.7 Traceability Coverage: 16/16 (100%)**

---

### Linter Patterns Included

| Pattern | Status | Evidence |
|---------|--------|----------|
| Action verbs (16) | ✅ PASS | title.pattern and definitions.action_verbs |
| EARS keywords | ✅ PASS | definitions.ears_keywords |
| Measurability patterns | ✅ PASS | definitions.measurability_patterns examples |
| Domain validation | ✅ PASS | 12 domains in enum |
| Agent pattern | ✅ PASS | Pattern: `^(fe|be|qa)-[a-z]+(-[a-z]+)?$` |

---

## Domain Enum Update

| # | Domain | From V1 | Updated in V4 |
|---|--------|---------|---------------|
| 1 | auth | ✅ | ✅ |
| 2 | layout | ✅ | ✅ |
| 3 | core | ❌ | ✅ (Added) |
| 4 | client | ✅ | ✅ |
| 5 | pilot | ✅ | ✅ |
| 6 | project | ✅ | ✅ |
| 7 | proposal | ✅ | ✅ |
| 8 | payment | ✅ | ✅ |
| 9 | deliverables | ✅ | ✅ |
| 10 | messaging | ✅ | ✅ |
| 11 | admin | ✅ | ✅ |
| 12 | notifications | ❌ | ✅ (Added) |

**Removed:** `general`, `public` (not business domains)  
**Added:** `core`, `notifications` (from DOMAINS.md)

---

## Metrics

| Metric | Value |
|--------|-------|
| Total lines | 501 |
| Total properties | 22 |
| Required fields | 6 |
| Valid JSON | ✅ Yes |
| additionalProperties | false (strict) |
| Nested objects | 9 |

---

## Comparison: V1 vs V4

| Feature | V1 | V4 | Change |
|---------|----|----|--------|
| Properties | 15 | 22 | +7 |
| Required fields | 5 | 6 | +1 (safety) |
| Domain count | 12 | 12 | Updated |
| Traceability fields | 0 | 7 | +7 |
| Execution tracking | 0 | 6 | +6 |
| Metrics tracking | 0 | 5 | +5 |
| additionalProperties | true | false | Stricter |
| stop_conditions | optional | required | Stricter |
| files.forbidden | required | required | ✅ |

---

## Key Improvements

1. **Safety is now required** - stop_conditions must have 3+ items
2. **Stricter validation** - additionalProperties: false
3. **12 business domains** - Aligned with DOMAINS.md
4. **Full traceability** - Epic, feature, linear, timestamps
5. **Execution tracking** - Status, gate, agent, branch
6. **Metrics built-in** - Tokens, coverage, quality score
7. **EARS validation** - Then clause must contain SHALL/SHOULD/MAY/MUST

---

## File Location

```
/mnt/user-data/outputs/ai-story-schema-v4.json
```

---

## Validation Commands

```bash
# Verify valid JSON
python3 -c "import json; json.load(open('/mnt/user-data/outputs/ai-story-schema-v4.json'))"

# Count properties
python3 -c "import json; d=json.load(open('/mnt/user-data/outputs/ai-story-schema-v4.json')); print(len(d['properties']))"

# Check domains
python3 -c "import json; d=json.load(open('/mnt/user-data/outputs/ai-story-schema-v4.json')); print(d['properties']['domain']['enum'])"

# Validate with ajv (if installed)
ajv validate -s ai-story-schema-v4.json -d sample-story.json
```

---

## Summary

**Gap 4 Status: ✅ COMPLETE**

- All 13 AI Stories V1 fields included
- All 16 V10.7 traceability/execution/metrics fields added
- Domain enum updated to 12 business domains
- Measurability patterns from linter documented
- Safety section now required
- Stricter validation with additionalProperties: false
- Ready for story validation

---

**Phase 1 Complete!**

All 4 gaps have been addressed:
1. ✅ DOMAINS.md created (755 lines, 12 domains)
2. ✅ START.md.template + ROLLBACK-PLAN.md.template created
3. ✅ CLAUDE-V2.1.md created (108 forbidden ops, E1-E5 levels)
4. ✅ ai-story-schema-v4.json created (22 properties, merged)
