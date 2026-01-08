# MAF V11.0.0 - Multi-Agent Framework
## Aerospace-Grade Autonomous Development System

**Version:** 11.0.0  
**Date:** January 8, 2026  
**Status:** BUILDING

---

## What is MAF?

MAF (Multi-Agent Framework) is a system for orchestrating autonomous AI agents to develop software with aerospace-grade safety and quality controls.

### Key Features

- **8-Gate Quality Pipeline** - Every change passes through 8 quality gates
- **108 Forbidden Operations** - Safety protocol prevents destructive actions
- **Independent QA** - Different agent validates code (no self-approval)
- **Git Worktree Isolation** - Each agent works in isolated workspace
- **External Enforcement** - Safety limits enforced externally, not by trust

---

## Directory Structure

```
maf-v11/
│
├── core/                        ← FRAMEWORK (Never changes per project)
│   ├── SAFETY-PROTOCOL.md         108 forbidden operations
│   ├── GATE-SYSTEM.md             8-gate definitions
│   ├── APPROVAL-LEVELS.md         L0-L5 approval matrix
│   ├── EMERGENCY-LEVELS.md        E1-E5 emergency stops
│   └── FMEA.md                    17 failure modes analyzed
│
├── templates/                   ← REUSABLE TEMPLATES
│   ├── test-template/
│   │   ├── LOCKED/                Framework (never modify)
│   │   │   ├── CLAUDE.md          Agent instructions
│   │   │   ├── docker-compose.yml Orchestration
│   │   │   ├── Dockerfile.agent   Agent image
│   │   │   └── scripts/           Merge watcher, entrypoint
│   │   └── CONFIGURABLE/          Your test config (edit this)
│   │       ├── .env.template      Credentials
│   │       ├── config.json        Test parameters
│   │       └── stories/           Your stories
│   └── story.template.json        AI Story schema
│
├── validation/                  ← TESTING TOOLS (Day 3)
├── operations/                  ← HOW TO RUN (Day 2-3)
├── database/                    ← DATABASE (Day 4-5)
└── projects/                    ← PROJECT IMPLEMENTATIONS
    ├── airview/                   AirView marketplace
    │   ├── AGENTS.md              29 agents defined
    │   └── DOMAINS.md             11 domains defined
    └── _template/                 Template for new projects
```

---

## Quick Start

### 1. Create a New Test

```bash
# Copy the template
cp -r templates/test-template/ my-test/

# Edit your credentials
cp my-test/CONFIGURABLE/.env.template my-test/.env
vim my-test/.env

# Add your stories
vim my-test/CONFIGURABLE/stories/wave1/STORY-001.json

# Run the test
cd my-test
docker compose up
```

### 2. Create a New Project

```bash
# Copy the project template
cp -r projects/_template/ projects/my-project/

# Define your domains
vim projects/my-project/DOMAINS.md

# Define your agents
vim projects/my-project/AGENTS.md
```

---

## Core Principles

### The "Change Only Goals" Pattern

```
LOCKED = The Airplane (never changes per flight)
CONFIGURABLE = The Flight Plan (changes every flight)
```

You don't modify safety systems for each test - you only change your goals/tasks.

### External Enforcement

```
❌ WRONG: "Dear agent, please don't exceed budget"
✅ RIGHT: External kill switch that terminates agent
```

Safety must be enforced externally, not requested.

### Independent QA

```
❌ WRONG: Dev agent reviews own code
✅ RIGHT: Different QA agent validates code
```

No self-approval allowed.

---

## Building Progress

| Phase | Days | Status |
|-------|------|--------|
| Phase 1: Core Framework | 1-3 | 🔄 In Progress |
| Phase 2: Database | 4-5 | ⬜ Not Started |
| Phase 3: Validation | 6-7 | ⬜ Not Started |
| Phase 4: First Test | 8-10 | ⬜ Not Started |

---

## Documentation

### Core Files (LOCKED - Don't Modify)
- [SAFETY-PROTOCOL.md](core/SAFETY-PROTOCOL.md) - 108 forbidden operations
- [GATE-SYSTEM.md](core/GATE-SYSTEM.md) - 8-gate definitions
- [APPROVAL-LEVELS.md](core/APPROVAL-LEVELS.md) - L0-L5 matrix
- [EMERGENCY-LEVELS.md](core/EMERGENCY-LEVELS.md) - E1-E5 procedures
- [FMEA.md](core/FMEA.md) - 17 failure modes

### Project-Specific
- [projects/airview/AGENTS.md](projects/airview/AGENTS.md) - AirView agents
- [projects/airview/DOMAINS.md](projects/airview/DOMAINS.md) - AirView domains

---

## Source Traceability

Every file includes a header showing exactly where content came from:

```markdown
<!--
MAF V11.0.0 SOURCE TRACEABILITY
Source Files:
  - /mnt/project/COMPLETE-SAFETY-REFERENCE.md
-->
```

This ensures nothing is invented - everything is extracted from validated documentation.

---

**Built by:** Boomerang Apps  
**Framework:** Based on 14 test iterations (V8 → V10.0.7)
