# Multi-Agent Framework (MAF)

> Production-ready framework for autonomous multi-agent software development

## Quick Start
```bash
# 1. Read the safety protocol
cat core/SAFETY-PROTOCOL.md

# 2. Understand domain boundaries
cat core/DOMAINS.md

# 3. Apply database migration
psql $DATABASE_URL -f reference/architecture/migrations/maf-complete-migration.sql

# 4. Setup agent worktrees
chmod +x reference/operations/maf-worktree.sh
./reference/operations/maf-worktree.sh setup
```

## Structure
```
maf/
├── .claude/                 # Claude-specific context
│   ├── context.md          # Session context primer
│   └── memory-anchors.md   # Key facts to remember
│
├── core/                    # Current canonical versions
│   ├── SAFETY-PROTOCOL.md  # 108 forbidden operations
│   ├── DOMAINS.md          # 12 domain boundaries
│   ├── AGENTS.md           # 29 agent specifications
│   └── PM-VALIDATOR-SECTIONS.md
│
├── reference/               # Supporting documentation
│   ├── architecture/       # Database, schemas, TypeScript
│   ├── operations/         # Templates, scripts, guides
│   ├── testing/            # Benchmarks and validation
│   └── research/           # Analysis and gap reports
│
├── learnings/               # Captured lessons
│   ├── PHASE-1-COMPLETION-REPORT.md
│   └── PHASE-2-COMPLETION-REPORT.md
│
└── sessions/                # Session handoffs
    └── SESSION-HANDOFF-MAF-GAP-EXECUTION.md
```

## Key Numbers

| Component | Count |
|-----------|-------|
| Agents | 29 (CTO, PM, 10 FE, 10 BE, 5 QA, DevOps, Security) |
| Domains | 12 (auth, client, pilot, project, proposal, payment, deliverables, messaging, admin, core, layout, notifications) |
| Gates | 8 (0-7) |
| Forbidden Operations | 108 |
| Database Tables | 9 |
| Signal Types | 21 |

## Core Documents

| Document | Purpose |
|----------|---------|
| [core/SAFETY-PROTOCOL.md](core/SAFETY-PROTOCOL.md) | Agent instructions, 108 forbidden ops, emergency levels |
| [core/DOMAINS.md](core/DOMAINS.md) | Domain boundaries and file ownership |
| [core/AGENTS.md](core/AGENTS.md) | 29 agent definitions with roles and models |
| [.claude/context.md](.claude/context.md) | Quick context primer for new sessions |

## License

MIT - Built by [Boomerang Apps](https://boomerangapps.com)
