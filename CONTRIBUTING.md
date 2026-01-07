# MAF Development Workflow

> How to professionally maintain and extend the MAF repository

## Branch Strategy
```
main                    # Protected - Production ready
├── develop            # Integration branch
├── feature/*          # New features
├── fix/*              # Bug fixes
└── docs/*             # Documentation updates
```

## Quick Start
```bash
# Start new work
git checkout develop && git pull
git checkout -b feature/my-feature

# Commit
git commit -m "feat: add new feature"

# Push and PR
git push -u origin feature/my-feature
# Create PR: feature/my-feature → develop
```

## Commit Types
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code restructure

## Protected Files
Changes to `core/` require PR review with justification.

See full guide in this file.
