# MAF V11.0.0 AUTHENTICATION GUIDE
## Claude Code CLI Authentication for Autonomous Agents

<!--
MAF V11.0.0 SOURCE TRACEABILITY
═══════════════════════════════════════════════════════════════════════════════
Generated: 2026-01-08
Source Files:
  - /mnt/project/CLAUDE-CODE-VM-AUTHENTICATION-PLAN.md
  - /mnt/project/BYPASS-MODE-AUTOMATION-GUIDE.md
  - /mnt/project/AUTONOMOUS-AGENT-SETUP-GUIDE.md
═══════════════════════════════════════════════════════════════════════════════
-->

**Version:** 11.0.0

---

## Overview

Claude Code CLI requires authentication before use. For autonomous execution in MAF, we use:

1. **API Key Authentication** (via ANTHROPIC_API_KEY)
2. **Bypass Mode** (via `--dangerously-skip-permissions`)
3. **Non-Root User** (required for bypass mode)

---

## Getting Your API Key

### Step 1: Create Anthropic Account

1. Go to https://console.anthropic.com
2. Create account or sign in
3. Navigate to Settings → API Keys

### Step 2: Generate API Key

1. Click "Create Key"
2. Name it (e.g., "MAF Production")
3. Copy the key (starts with `sk-ant-api03-...`)

⚠️ **IMPORTANT:** Save this key securely. It won't be shown again.

### Step 3: Set in Environment

```bash
# In your .env file
ANTHROPIC_API_KEY=sk-ant-api03-your-key-here

# Or export directly
export ANTHROPIC_API_KEY=sk-ant-api03-your-key-here
```

---

## Autonomous Execution Mode

### The --dangerously-skip-permissions Flag

For autonomous agent execution, Claude Code CLI must run without prompting for permissions:

```bash
# Interactive mode (NOT for MAF)
claude -p "Your prompt"
# Will ask: "Accept permissions? (y/n)"

# Autonomous mode (REQUIRED for MAF)
claude -p "Your prompt" --dangerously-skip-permissions
# Runs without prompting
```

### Why "Dangerously"?

The flag is named "dangerously" because it:
- Skips all permission confirmations
- Allows file modifications without approval
- Allows command execution without approval

**In MAF, safety is enforced externally** (through CLAUDE.md forbidden operations, kill switch, stuck detection) rather than through Claude's permission system.

---

## Non-Root User Requirement

### The Problem

```bash
# This FAILS as root:
root@container:~# claude --dangerously-skip-permissions
Error: Cannot use --dangerously-skip-permissions with root privileges
```

### The Solution

```dockerfile
# In Dockerfile.agent
RUN useradd -m -s /bin/bash claudeuser
USER claudeuser

# Now this WORKS:
claudeuser@container:~$ claude --dangerously-skip-permissions
# Claude starts successfully
```

### Why This Requirement Exists

Anthropic designed this as a security feature:
- Root has unlimited system access
- Combining root + skip-permissions would be dangerous
- Non-root limits potential damage

---

## Docker Authentication Flow

### In docker-compose.yml

```yaml
services:
  agent:
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    command: >
      bash -c "claude -p '...' --dangerously-skip-permissions"
```

### Complete Working Pattern

```yaml
# docker-compose.yml
services:
  wave1-fe-dev:
    build:
      context: .
      dockerfile: Dockerfile.agent
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - AGENT_ID=wave1-fe-dev
    command: >
      bash -c "claude -p 'Read CLAUDE.md and execute story AUTH-FE-001' --dangerously-skip-permissions --output-format stream-json"
```

```dockerfile
# Dockerfile.agent
FROM node:20-slim
RUN npm install -g @anthropic-ai/claude-code
RUN useradd -m -s /bin/bash claudeuser
USER claudeuser
WORKDIR /workspace
CMD ["bash"]
```

---

## Validating Authentication

### Test API Key

```bash
# Quick API test
curl -X POST https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

**Expected:** JSON response with `"type": "message"`

### Test Claude CLI

```bash
# Test Claude CLI (interactive)
claude -p "Say hello"

# Test with skip-permissions (must be non-root)
claude -p "Say hello" --dangerously-skip-permissions
```

### Test in Docker

```bash
# Build and run test
docker build -f LOCKED/Dockerfile.agent -t maf-agent .
docker run --rm -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY maf-agent \
  bash -c "claude -p 'Say hello' --dangerously-skip-permissions"
```

---

## Troubleshooting

### "Invalid API Key"

**Symptoms:**
```
Error: authentication_error - Invalid API key
```

**Solutions:**
1. Check key starts with `sk-ant-api03-`
2. Verify no extra spaces or newlines
3. Regenerate key if compromised

### "Cannot use --dangerously-skip-permissions with root"

**Symptoms:**
```
Error: Cannot use --dangerously-skip-permissions with root privileges
```

**Solutions:**
1. Add `USER claudeuser` to Dockerfile
2. Don't use `docker run --user root`
3. Ensure non-root user exists in image

### "Claude command not found"

**Symptoms:**
```
bash: claude: command not found
```

**Solutions:**
1. Add `npm install -g @anthropic-ai/claude-code` to Dockerfile
2. Ensure PATH includes npm global bin
3. Verify npm installed in base image

### API Rate Limiting

**Symptoms:**
```
Error: rate_limit_error
```

**Solutions:**
1. Wait and retry (automatic backoff)
2. Use different models for different agents (Haiku for QA)
3. Check Anthropic dashboard for limits

---

## Security Best Practices

### API Key Storage

```bash
# ✅ GOOD: Environment variable
export ANTHROPIC_API_KEY=sk-ant-...

# ✅ GOOD: .env file (gitignored)
echo "ANTHROPIC_API_KEY=sk-ant-..." > .env
echo ".env" >> .gitignore

# ❌ BAD: Hardcoded in code
const API_KEY = "sk-ant-..."  # Never do this!

# ❌ BAD: In docker-compose.yml
environment:
  - ANTHROPIC_API_KEY=sk-ant-...  # Use ${ANTHROPIC_API_KEY} instead
```

### Key Rotation

1. Generate new key in Anthropic console
2. Update .env file
3. Restart containers
4. Revoke old key

### Monitoring Usage

- Check https://console.anthropic.com/usage
- Set up billing alerts
- Track token usage per agent

---

## Quick Reference

| Requirement | Value |
|-------------|-------|
| API Key Format | `sk-ant-api03-...` |
| Environment Variable | `ANTHROPIC_API_KEY` |
| CLI Flag | `--dangerously-skip-permissions` |
| User Requirement | Non-root (e.g., `claudeuser`) |
| Output Format | `--output-format stream-json` |

---

**Document Status:** OPERATIONS (update as needed)
