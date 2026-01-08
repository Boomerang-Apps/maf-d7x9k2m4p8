# MAF V11.0.0 DEPLOYMENT GUIDE
## Docker & VM Setup for Multi-Agent Execution

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - /mnt/project/AUTONOMOUS-AGENT-SETUP-GUIDE.md
  - /mnt/project/DOCKER-MULTI-AGENT-IMPLEMENTATION-GUIDE.md
  - /mnt/project/BYPASS-MODE-AUTOMATION-GUIDE.md
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0

---

## Prerequisites

### Required Software

| Software | Minimum Version | Check Command |
|----------|-----------------|---------------|
| Docker | 24.0+ | `docker --version` |
| Docker Compose | v2.0+ | `docker compose version` |
| Git | 2.30+ | `git --version` |
| jq | 1.6+ | `jq --version` |
| curl | Any | `curl --version` |

### Required Accounts

| Service | Purpose | Get Credentials |
|---------|---------|-----------------|
| Anthropic | AI API access | https://console.anthropic.com/settings/keys |
| Slack | Notifications | https://api.slack.com/apps → Incoming Webhooks |
| GitHub | Code repository | https://github.com/settings/tokens |
| Supabase | Database | https://supabase.com/dashboard |

---

## Quick Start

### 1. Clone MAF V11

```bash
git clone https://github.com/your-org/maf-v11.git
cd maf-v11
```

### 2. Create Test Package

```bash
# Copy the test template
cp -r templates/test-template/ my-test/
cd my-test/

# Configure credentials
cp CONFIGURABLE/.env.template .env
vim .env  # Add your API keys
```

### 3. Add Your Stories

```bash
# Edit or replace the example story
vim CONFIGURABLE/stories/wave1/AUTH-FE-001.json
```

### 4. Validate

```bash
# Quick check
../validation/smoke-test.sh

# Full validation
../validation/pm-validator-v6.0.sh
```

### 5. Execute

```bash
# Build and run
docker compose -f LOCKED/docker-compose.yml up --build
```

---

## Detailed Setup

### Docker Configuration

#### Non-Root User (REQUIRED)

The Dockerfile MUST use a non-root user for `--dangerously-skip-permissions` to work:

```dockerfile
# In LOCKED/Dockerfile.agent
RUN useradd -m -s /bin/bash claudeuser
USER claudeuser
```

**Why?** Claude Code CLI blocks `--dangerously-skip-permissions` when running as root.

#### Volume Mounts

```yaml
# In LOCKED/docker-compose.yml
volumes:
  - ./signals:/workspace/.claude/signals    # Signal coordination
  - ./worktrees/${AGENT_NAME}:/workspace/code  # Git worktree
```

### Git Worktree Setup

Each agent needs an isolated worktree:

```bash
# Create worktrees for agents
git worktree add worktrees/fe-auth -b feature/AUTH-FE-001 main
git worktree add worktrees/be-auth -b feature/AUTH-BE-001 main
git worktree add worktrees/qa-auth -b qa/wave1 main
```

### Signal Directory

Create the signal directory structure:

```bash
mkdir -p signals
mkdir -p worktrees
```

---

## VM Deployment

### Single VM (Development)

For development or small tests:

```bash
# 1. Create DigitalOcean droplet
doctl compute droplet create maf-dev \
  --image docker-20-04 \
  --size s-4vcpu-8gb \
  --region nyc1

# 2. SSH and setup
ssh root@[IP]
git clone https://github.com/your-org/maf-v11.git
cd maf-v11

# 3. Run
docker compose -f LOCKED/docker-compose.yml up
```

### Multi-VM (Production)

For larger agent counts (20+ agents):

```
┌─────────────────────────────────────────────────────────────────┐
│                    MULTI-VM ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  VM 1: Orchestration                VM 2: Auth Domain           │
│  ───────────────────                ─────────────────           │
│  - merge-watcher.sh                 - fe-auth agent            │
│  - Signal directory (NFS)           - be-auth agent            │
│  - Dashboard                        - qa-auth agent            │
│                                                                 │
│  VM 3: Client Domain                VM 4: Payment Domain        │
│  ────────────────────               ──────────────────          │
│  - fe-client agent                  - fe-payment agent          │
│  - be-client agent                  - be-payment agent          │
│  - qa-core agent                    - qa-transactions agent     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Setup Steps

1. **Create VMs** (one per domain + orchestration)
2. **Setup shared storage** (NFS for signals directory)
3. **Clone MAF** to each VM
4. **Configure domain** in each VM's .env
5. **Start orchestration first**, then domain agents

---

## Monitoring

### Real-Time Logs

```bash
# All containers
docker compose logs -f

# Specific agent
docker logs -f wave1-fe-dev

# With safety detector
docker compose logs -f | ./validation/safety-detector.sh
```

### Slack Notifications

Configure in .env:

```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T.../B.../xxx
```

Events sent to Slack:
- Pipeline start
- Gate completions
- Errors and failures
- Cost reports
- Pipeline completion

### Dashboard (Optional)

Use Dozzle for web-based log viewing:

```yaml
# Add to docker-compose.yml
services:
  dozzle:
    image: amir20/dozzle:latest
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Access at: http://localhost:8080

---

## Troubleshooting

### Common Issues

#### "Cannot use --dangerously-skip-permissions with root"

**Cause:** Running as root user  
**Fix:** Ensure Dockerfile has `USER claudeuser` (non-root)

#### Container exits immediately

**Cause:** Missing API key or invalid command  
**Fix:** Check .env file, verify ANTHROPIC_API_KEY is valid

#### "Permission denied" in worktree

**Cause:** Root created files, non-root can't access  
**Fix:** 
```bash
chown -R 1000:1000 worktrees/
```

#### Agents not coordinating

**Cause:** Signal directory not shared  
**Fix:** Ensure all agents mount the same ./signals directory

### Debug Mode

Run a single agent interactively:

```bash
docker compose run --rm wave1-fe-dev bash
# Inside container:
claude -p "Read CLAUDE.md" --dangerously-skip-permissions
```

---

## Resource Requirements

### Minimum (2-4 agents)

- **CPU:** 4 cores
- **RAM:** 8 GB
- **Disk:** 50 GB SSD
- **Cost:** ~$40/month (DigitalOcean)

### Recommended (10-20 agents)

- **CPU:** 8 cores
- **RAM:** 16 GB
- **Disk:** 100 GB SSD
- **Cost:** ~$80/month

### Production (20+ agents)

- **Multiple VMs** (one per domain)
- **Shared storage** (NFS or similar)
- **Load balancer** for dashboard
- **Cost:** ~$200-400/month

---

## Next Steps

1. Read [AUTHENTICATION.md](AUTHENTICATION.md) for Claude Code setup
2. Read [MONITORING.md](MONITORING.md) for observability setup
3. Run your first test with the example story

---

**Document Status:** OPERATIONS (update as needed)
