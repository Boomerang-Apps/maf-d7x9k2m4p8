# AI Stories Methodology: Implementation Plan

**Based on:** Gap Analysis V10.7 vs AI Stories V1  
**Goal:** Create complete, unified AI Stories methodology  
**Date:** January 7, 2026

---

# EXECUTIVE SUMMARY

## Current State

| Component | V10.7 | AI Stories V1 | Gap |
|-----------|-------|---------------|-----|
| Schema | ai-story-schema-v3.json | ai-story.schema.json | Need merge |
| Linter | PM Validator (bash) | index.ts (TypeScript) | Need merge |
| Documentation | Scattered | README.md | Need consolidation |
| Examples | 2 examples | sample-stories.json | Need more |

## Target State

```
ai-stories/
├── SCHEMA.md                    # Human-readable specification
├── ai-story-schema-v4.json      # Machine-readable JSON Schema
├── story-linter.ts              # TypeScript validation tool
├── EARS-REFERENCE.md            # EARS notation guide
├── EXAMPLES/
│   ├── frontend-story.json
│   ├── backend-story.json
│   ├── database-story.json
│   └── qa-story.json
└── TEMPLATES/
    ├── story-template.json
    └── story-template.md
```

---

# PHASE 1: SCHEMA CONSOLIDATION

## Deliverable: ai-story-schema-v4.json

### Task 1.1: Merge Required Fields

**Current V10.7 Required:**
```json
["id", "title", "type", "priority", "story", "acceptance_criteria"]
```

**New V4 Required:**
```json
["id", "title", "domain", "objective", "acceptance_criteria", "files", "safety"]
```

| Field | Source | Notes |
|-------|--------|-------|
| id | Both | Keep V1 pattern validation |
| title | V1 | Add action verb requirement |
| domain | V1 | Business domain (12 options) |
| objective | V1 | Structured as_a/i_want/so_that |
| acceptance_criteria | Both | Merge EARS + Traceability |
| files | V1 | Include forbidden as required |
| safety | V1 | Include stop_conditions |

---

### Task 1.2: Define ID Format

**Decision:** Support both patterns

```json
"id": {
  "type": "string",
  "oneOf": [
    {
      "pattern": "^[A-Z]+-[A-Z]+-[0-9]{3}$",
      "description": "Domain format: AUTH-FE-001"
    },
    {
      "pattern": "^WAVE[0-9]+-[A-Z]+-[0-9]+$",
      "description": "Wave format: WAVE1-FE-001"
    }
  ]
}
```

---

### Task 1.3: Define Title with Action Verb

```json
"title": {
  "type": "string",
  "minLength": 10,
  "maxLength": 100,
  "pattern": "^(Create|Add|Update|Fix|Remove|Implement|Configure|Enable|Disable|Refactor|Migrate|Build|Setup|Initialize|Delete|Modify)",
  "description": "Action-oriented title starting with verb"
}
```

**Valid Action Verbs (16):**
1. Create - New component/file
2. Add - New feature to existing
3. Update - Modify existing
4. Fix - Bug fix
5. Remove - Delete functionality
6. Implement - Complex feature
7. Configure - Setup/config
8. Enable - Turn on feature
9. Disable - Turn off feature
10. Refactor - Code improvement
11. Migrate - Move/upgrade
12. Build - Construct system
13. Setup - Initial configuration
14. Initialize - First-time setup
15. Delete - Remove entirely
16. Modify - Change behavior

---

### Task 1.4: Define Domain Enum

**Decision:** Use business domains (more specific)

```json
"domain": {
  "type": "string",
  "enum": [
    "auth",
    "client", 
    "pilot",
    "project",
    "proposal",
    "messaging",
    "payment",
    "deliverables",
    "admin",
    "layout",
    "general",
    "public"
  ],
  "description": "Business domain for ownership"
}
```

**Optional:** Add `technical_domain` for V10.7 compatibility:
```json
"technical_domain": {
  "type": "string",
  "enum": ["frontend", "backend", "database", "infrastructure", "testing", "documentation"]
}
```

---

### Task 1.5: Define Agent Pattern

```json
"agent": {
  "type": "string",
  "pattern": "^[a-z]+-[a-z]+-[a-z]+$",
  "description": "Agent ID: domain-type-role",
  "examples": ["auth-fe-dev", "payment-be-dev", "client-qa"]
}
```

---

### Task 1.6: Define Priority & Complexity

```json
"priority": {
  "type": "string",
  "enum": ["P0-Critical", "P1-High", "P2-Medium", "P3-Low"],
  "default": "P2-Medium"
},
"complexity": {
  "type": "string",
  "enum": ["S", "M", "L", "XL"],
  "description": "S(1-2h), M(2-4h), L(4-8h), XL(8+h)"
},
"estimate_hours": {
  "type": "number",
  "minimum": 0.5,
  "maximum": 40
}
```

---

### Task 1.7: Define Objective (Structured)

```json
"objective": {
  "type": "object",
  "required": ["as_a", "i_want", "so_that"],
  "properties": {
    "as_a": {
      "type": "string",
      "minLength": 5,
      "description": "User persona"
    },
    "i_want": {
      "type": "string", 
      "minLength": 10,
      "description": "Desired capability"
    },
    "so_that": {
      "type": "string",
      "minLength": 10,
      "description": "Business benefit"
    }
  }
}
```

---

### Task 1.8: Define Scope

```json
"scope": {
  "type": "object",
  "properties": {
    "in_scope": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Explicitly included items"
    },
    "out_of_scope": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Explicitly excluded items"
    },
    "definitions": {
      "type": "object",
      "additionalProperties": { "type": "string" },
      "description": "Term glossary"
    }
  }
}
```

---

### Task 1.9: Define Acceptance Criteria (Merged)

```json
"acceptance_criteria": {
  "type": "array",
  "minItems": 3,
  "items": {
    "type": "object",
    "required": ["id", "description"],
    "properties": {
      // From V1 - EARS Structure
      "id": {
        "type": "string",
        "pattern": "^AC-[0-9]+$"
      },
      "title": { "type": "string" },
      "ears_pattern": {
        "type": "string",
        "enum": ["ubiquitous", "event-driven", "state-driven", "unwanted", "complex"]
      },
      "given": { "type": "string" },
      "when": { "type": "string" },
      "then": { "type": "string" },
      "threshold": { 
        "type": "string",
        "description": "Measurable value (ms, %, count)"
      },
      
      // From V10.7 - Traceability
      "description": { "type": "string" },
      "implementation_file": { "type": "string" },
      "implementation_function": { "type": "string" },
      "test_file": { "type": "string" },
      "test_function": { "type": "string" },
      "verified": { "type": "boolean", "default": false },
      "coverage": { "type": "number", "minimum": 0, "maximum": 100 }
    }
  }
}
```

---

### Task 1.10: Define Files (with Forbidden Required)

```json
"files": {
  "type": "object",
  "required": ["create", "forbidden"],
  "properties": {
    "create": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Files to create"
    },
    "modify": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Files to modify"
    },
    "forbidden": {
      "type": "array",
      "minItems": 1,
      "items": { "type": "string" },
      "description": "Files agent must NOT touch"
    }
  }
}
```

**Default Forbidden Patterns:**
- `.env*` - Environment files
- `*.key`, `*.pem` - Credentials
- `supabase/migrations/*` - Unless DB story
- `src/lib/core/**` - Core utilities
- Other domain paths

---

### Task 1.11: Define API Contract

```json
"api_contract": {
  "type": "object",
  "properties": {
    "endpoint": {
      "type": "string",
      "pattern": "^(GET|POST|PUT|PATCH|DELETE) /",
      "description": "HTTP method and path"
    },
    "request": {
      "type": "object",
      "properties": {
        "type_name": { "type": "string" },
        "fields": {
          "type": "object",
          "additionalProperties": {
            "type": "object",
            "properties": {
              "type": { "type": "string" },
              "required": { "type": "boolean" },
              "validation": { "type": "string" }
            }
          }
        }
      }
    },
    "response": {
      "type": "object",
      "properties": {
        "success_type": { "type": "string" },
        "error_codes": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "code": { "type": "string" },
              "status": { "type": "integer" },
              "message": { "type": "string" }
            }
          }
        }
      }
    }
  }
}
```

---

### Task 1.12: Define Tests

```json
"tests": {
  "type": "object",
  "required": ["commands"],
  "properties": {
    "commands": {
      "type": "array",
      "minItems": 1,
      "items": { "type": "string" },
      "description": "Test execution commands"
    },
    "coverage_threshold": {
      "type": "number",
      "minimum": 0,
      "maximum": 100,
      "default": 80
    },
    "unit_tests": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Unit test descriptions"
    },
    "integration_tests": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Integration test descriptions"
    }
  }
}
```

---

### Task 1.13: Define Dependencies (Extended)

```json
"dependencies": {
  "type": "object",
  "properties": {
    "stories": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Story IDs that must complete first"
    },
    "contracts": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Contract names required"
    },
    "infrastructure": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Infrastructure requirements"
    }
  }
}
```

---

### Task 1.14: Define Safety (Merged)

```json
"safety": {
  "type": "object",
  "required": ["stop_conditions"],
  "properties": {
    // From V1
    "max_iterations": {
      "type": "integer",
      "minimum": 5,
      "maximum": 50,
      "default": 25
    },
    "token_budget": {
      "type": "integer",
      "minimum": 10000,
      "maximum": 500000,
      "default": 200000
    },
    "timeout_minutes": {
      "type": "integer",
      "minimum": 10,
      "maximum": 480,
      "default": 120
    },
    "stop_conditions": {
      "type": "array",
      "minItems": 3,
      "items": { "type": "string" }
    },
    "escalation_triggers": {
      "type": "array",
      "items": { "type": "string" }
    },
    
    // From V10.7
    "dal_level": {
      "type": "string",
      "enum": ["A", "B", "C", "D", "E"],
      "description": "Design Assurance Level (DO-178C)"
    },
    "requires_human_approval": {
      "type": "boolean",
      "default": false
    },
    "approval_reason": {
      "type": "string"
    }
  }
}
```

---

### Task 1.15: Define Additional Fields

```json
"implementation_hints": {
  "type": "array",
  "items": { "type": "string" },
  "description": "Guidance for implementing agent"
},

"rollback_plan": {
  "type": "object",
  "properties": {
    "git_strategy": { "type": "string" },
    "database_rollback": { "type": "string" },
    "recovery_steps": {
      "type": "array",
      "items": { "type": "string" }
    }
  }
},

"definition_of_done": {
  "type": "array",
  "items": { "type": "string" },
  "description": "Checklist for completion"
},

// From V10.7 - Traceability
"traceability": {
  "type": "object",
  "properties": {
    "requirement_source": { "type": "string" },
    "parent_requirement": { "type": "string" },
    "verification_method": {
      "type": "string",
      "enum": ["test", "inspection", "analysis", "demonstration"]
    },
    "verification_status": {
      "type": "string",
      "enum": ["not_started", "in_progress", "passed", "failed"]
    }
  }
},

// From V10.7 - Tracking
"status": {
  "type": "string",
  "enum": ["backlog", "ready", "in_progress", "review", "done", "blocked"]
},
"gate": {
  "type": "integer",
  "minimum": 0,
  "maximum": 7
},
"actual_hours": { "type": "number" },
"actual_tokens": { "type": "integer" },
"actual_cost": { "type": "number" }
```

---

# PHASE 2: LINTER ENHANCEMENT

## Deliverable: Enhanced validation

### Task 2.1: Add Measurability Check

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
];

function checkMeasurability(criterion: string): boolean {
  return MEASURABILITY_PATTERNS.some(p => p.test(criterion));
}
```

---

### Task 2.2: Add Anti-Pattern Detection

```typescript
const ANTI_PATTERNS = [
  { pattern: /make it fast/i, fix: 'Use "within 200ms"' },
  { pattern: /handle errors/i, fix: 'Use "return 400 with {code, message}"' },
  { pattern: /use best practices/i, fix: 'Reference specific file' },
  { pattern: /good test coverage/i, fix: 'Use "≥80% coverage"' },
  { pattern: /should be secure/i, fix: 'Specify: bcrypt, no plaintext' },
  { pattern: /improve performance/i, fix: 'Use "reduce to <500ms"' },
  { pattern: /properly validate/i, fix: 'Specify validation rules' },
];
```

---

### Task 2.3: Add Score System

```typescript
function calculateScore(story: Story, errors: LintError[]): number {
  let score = 100;
  
  // Deduct for errors
  errors.forEach(e => {
    if (e.severity === 'error') score -= 20;
    if (e.severity === 'warning') score -= 5;
  });
  
  // Bonus for completeness
  if (story.scope) score += 5;
  if (story.api_contract) score += 5;
  if (story.rollback_plan) score += 5;
  if (story.implementation_hints?.length) score += 5;
  
  return Math.max(0, Math.min(100, score));
}
```

**Score Thresholds:**
- 🟢 95-100: Ready for execution
- 🟡 80-94: Minor fixes needed
- 🟠 60-79: Significant gaps
- 🔴 0-59: Not ready

---

### Task 2.4: Add to PM Validator

Add new section to pm-validator-v5.7.sh:

```bash
# ─────────────────────────────────────────────────────────────────────────────
# SECTION R: AI STORY QUALITY (R1-R10)
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "═══ SECTION R: AI STORY QUALITY ═══"

# R1: All stories have action verb titles
# R2: All stories have files.forbidden
# R3: All stories have min 3 acceptance criteria
# R4: All ACs have measurable thresholds
# R5: No anti-patterns detected
# R6: All stories have stop_conditions
# R7: Average story score ≥95
# R8: All stories have domain assigned
# R9: All agents follow pattern
# R10: All dependencies exist
```

---

# PHASE 3: DOCUMENTATION

## Deliverable: Complete AI Stories Documentation

### Task 3.1: Create SCHEMA.md

Human-readable specification with:
- All field definitions
- Examples for each field
- Validation rules
- Common mistakes

---

### Task 3.2: Create EARS-REFERENCE.md

| Pattern | Template | When to Use |
|---------|----------|-------------|
| Ubiquitous | The system SHALL [behavior] | Always true |
| Event-Driven | WHEN [trigger] THEN SHALL [behavior] | On event |
| State-Driven | WHILE [state] SHALL [behavior] | During state |
| Unwanted | IF [condition] THEN SHALL [handling] | Error cases |

**Measurability Examples:**
- Time: "within 2000ms", "under 500ms"
- Status: "return 200", "respond with 401"
- Count: "maximum 5 attempts", "at least 3 items"
- Message: 'display "Invalid email"'
- Percentage: "≥80% coverage"

---

### Task 3.3: Create Example Stories

**Frontend Story Example:**
```json
{
  "id": "AUTH-FE-001",
  "title": "Create LoginForm component with email validation",
  "domain": "auth",
  "agent": "auth-fe-dev",
  ...
}
```

**Backend Story Example:**
```json
{
  "id": "AUTH-BE-001",
  "title": "Implement login API endpoint with JWT",
  "domain": "auth",
  "agent": "auth-be-dev",
  "api_contract": { ... },
  ...
}
```

---

### Task 3.4: Create Story Template

Fillable template for creating new stories with all fields and guidance.

---

# PHASE 4: INTEGRATION

## Deliverable: Integrated tooling

### Task 4.1: GitHub Actions Workflow

```yaml
name: Story Validation
on: [push, pull_request]

jobs:
  validate-stories:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate Stories
        run: |
          npx ts-node story-linter.ts stories/*.json --strict
```

---

### Task 4.2: Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

if git diff --cached --name-only | grep -q "stories/"; then
  npm run lint:stories
  if [ $? -ne 0 ]; then
    echo "❌ Story validation failed"
    exit 1
  fi
fi
```

---

### Task 4.3: VS Code Extension Config

```json
{
  "json.schemas": [
    {
      "fileMatch": ["stories/*.json", "*-story.json"],
      "url": "./ai-story-schema-v4.json"
    }
  ]
}
```

---

# IMPLEMENTATION TIMELINE

| Phase | Tasks | Effort | Priority |
|-------|-------|--------|----------|
| **Phase 1** | Schema V4 | 2-3 hours | P0 |
| **Phase 2** | Linter Enhancement | 2-3 hours | P1 |
| **Phase 3** | Documentation | 1-2 hours | P1 |
| **Phase 4** | Integration | 1 hour | P2 |

**Total Effort:** 6-9 hours

---

# VALIDATION CHECKLIST

Before declaring AI Stories methodology complete:

- [ ] ai-story-schema-v4.json created and validates
- [ ] All 14 topic gaps addressed
- [ ] Story linter has score system
- [ ] Story linter detects anti-patterns
- [ ] Story linter checks measurability
- [ ] PM Validator Section R added
- [ ] SCHEMA.md documentation complete
- [ ] EARS-REFERENCE.md created
- [ ] 4 example stories created (FE, BE, DB, QA)
- [ ] Story template created
- [ ] GitHub Actions workflow documented
- [ ] Pre-commit hook documented

---

# NEXT STEPS

**Confirm this plan, then execute:**

1. **Create ai-story-schema-v4.json** - Merged schema
2. **Create SCHEMA.md** - Human documentation
3. **Create EARS-REFERENCE.md** - Notation guide
4. **Create example stories** - 4 types
5. **Update PM Validator** - Section R
6. **Test everything** - Validate schema works

**Ready to start Phase 1?**
