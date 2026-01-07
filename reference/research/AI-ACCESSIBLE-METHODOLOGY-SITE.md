# AI-Accessible Methodology Site: Complete Solution

**Date:** January 7, 2026  
**Purpose:** Create a secure online site that Claude can access with all your methodology organized

---

## Executive Summary

**Yes, you can create a site that Claude.ai can access.** Here's how:

| Approach | Effort | Cost | Claude Access |
|----------|--------|------|---------------|
| **GitHub Pages + llms.txt** | Low | Free | ✅ Via web fetch |
| **MkDocs Material** | Medium | Free | ✅ Via web fetch |
| **Mintlify Docs** | Low | Free tier | ✅ Auto llms.txt |
| **GitBook** | Low | Free tier | ✅ Via web fetch |

**Recommended: GitHub Pages + llms.txt + MkDocs Material**

---

## The llms.txt Standard

<quote source="llmstxt.org">
"We propose adding a /llms.txt markdown file to websites to provide LLM-friendly content. This file offers brief background information, guidance, and links to detailed markdown files. llms.txt markdown is human and LLM readable."
</quote>

### What llms.txt Does

```
YOUR SITE                          CLAUDE.AI
─────────                          ─────────
                                   
yoursite.com/llms.txt    ───────►  Claude fetches this first
    │                              Gets overview + structure
    │
    ├── /llms-full.txt   ───────►  Claude fetches full content
    │   (all docs in one file)     Complete methodology in context
    │
    └── /docs/*.md       ───────►  Claude fetches specific docs
        (individual pages)         On-demand deep dives
```

### Example llms.txt for Your Methodology

```markdown
# Eli's Multi-Agent Development Methodology

> A comprehensive framework for autonomous multi-agent software development
> using Claude Code, Docker containers, and database-driven coordination.
> Version 10.0.6 | Last updated: January 2026

## Core Documents (Start Here)

- [Workflow Overview](https://eli-methodology.github.io/docs/core/WORKFLOW-V10.md): 
  The 8-gate development workflow for autonomous agents
- [Safety Protocol](https://eli-methodology.github.io/docs/core/SAFETY-PROTOCOL.md): 
  Forbidden operations and safety guardrails
- [PM Validator](https://eli-methodology.github.io/docs/core/PM-VALIDATOR.md): 
  Validation system v5.5 for quality assurance

## Locked Patterns (Cannot Modify)

- [Locked Registry](https://eli-methodology.github.io/docs/LOCKED/LOCKED-REGISTRY.yaml): 
  Master list of validated, protected patterns
- [Git Worktree Strategy](https://eli-methodology.github.io/docs/LOCKED/GIT-WORKTREE.md): 
  Multi-agent isolation approach
- [8-Gate System](https://eli-methodology.github.io/docs/LOCKED/8-GATE-SYSTEM.md): 
  Quality gate sequence

## Reference

- [Agent Prompts](https://eli-methodology.github.io/docs/reference/AGENT-PROMPTS.md): 
  Kickstart prompts for all agent types
- [Database Schema](https://eli-methodology.github.io/docs/reference/DATABASE-SCHEMA.md): 
  Coordination tables and signals

## Full Content

- [Complete Methodology](https://eli-methodology.github.io/llms-full.txt): 
  All documentation in a single file for full context
```

---

## Solution 1: GitHub Pages + MkDocs (Recommended)

### Why This Approach

- **Free hosting** on GitHub Pages
- **Version controlled** in your repo
- **Auto-generates** llms.txt
- **Beautiful UI** for humans too
- **Claude can fetch** any page

### Setup Steps

#### Step 1: Create GitHub Repository

```bash
# Create new repo
gh repo create eli-methodology --public

# Clone it
git clone https://github.com/YOUR_USERNAME/eli-methodology.git
cd eli-methodology
```

#### Step 2: Install MkDocs Material

```bash
pip install mkdocs-material
```

#### Step 3: Create Project Structure

```
eli-methodology/
├── mkdocs.yml                    # Configuration
├── docs/
│   ├── index.md                  # Home page
│   ├── core/
│   │   ├── WORKFLOW-V10.md
│   │   ├── SAFETY-PROTOCOL.md
│   │   └── PM-VALIDATOR.md
│   ├── LOCKED/
│   │   ├── LOCKED-REGISTRY.yaml
│   │   ├── GIT-WORKTREE.md
│   │   └── 8-GATE-SYSTEM.md
│   ├── reference/
│   │   ├── AGENT-PROMPTS.md
│   │   └── DATABASE-SCHEMA.md
│   └── claude-context/
│       ├── CONTEXT-PRIMER.md
│       └── CHANGE-PROTOCOL.md
├── llms.txt                      # AI navigation file
└── llms-full.txt                 # All content combined
```

#### Step 4: Configure MkDocs

```yaml
# mkdocs.yml
site_name: Eli's Multi-Agent Methodology
site_url: https://YOUR_USERNAME.github.io/eli-methodology
site_description: Framework for autonomous multi-agent development

theme:
  name: material
  palette:
    primary: indigo
  features:
    - navigation.instant
    - navigation.sections
    - search.suggest

nav:
  - Home: index.md
  - Core:
    - Workflow v10: core/WORKFLOW-V10.md
    - Safety Protocol: core/SAFETY-PROTOCOL.md
    - PM Validator: core/PM-VALIDATOR.md
  - Locked Patterns:
    - Registry: LOCKED/LOCKED-REGISTRY.yaml
    - Git Worktree: LOCKED/GIT-WORKTREE.md
    - 8-Gate System: LOCKED/8-GATE-SYSTEM.md
  - Reference:
    - Agent Prompts: reference/AGENT-PROMPTS.md
    - Database Schema: reference/DATABASE-SCHEMA.md
  - Claude Context:
    - Context Primer: claude-context/CONTEXT-PRIMER.md
    - Change Protocol: claude-context/CHANGE-PROTOCOL.md

plugins:
  - search
```

#### Step 5: Create llms.txt Generator Script

```python
#!/usr/bin/env python3
# scripts/generate-llms-txt.py
"""Generate llms.txt and llms-full.txt from docs folder"""

import os
from pathlib import Path

SITE_URL = "https://YOUR_USERNAME.github.io/eli-methodology"
DOCS_DIR = Path("docs")

def generate_llms_txt():
    """Generate the llms.txt navigation file"""
    
    content = f"""# Eli's Multi-Agent Development Methodology

> A comprehensive framework for autonomous multi-agent software development
> using Claude Code, Docker containers, and database-driven coordination.
> Version 10.0.6 | Last updated: January 2026

## Important Notes for AI Assistants

- Check LOCKED-REGISTRY.yaml before suggesting modifications to any pattern
- Use the Change Request Protocol before implementing any changes
- Existing patterns should be extended, not duplicated

## Core Documents (Start Here)

"""
    
    # Add core docs
    core_docs = [
        ("core/WORKFLOW-V10.md", "The 8-gate development workflow"),
        ("core/SAFETY-PROTOCOL.md", "Forbidden operations and guardrails"),
        ("core/PM-VALIDATOR.md", "Validation system v5.5"),
    ]
    
    for path, desc in core_docs:
        content += f"- [{path}]({SITE_URL}/docs/{path}): {desc}\n"
    
    content += "\n## Locked Patterns (Cannot Modify Without Approval)\n\n"
    
    locked_docs = [
        ("LOCKED/LOCKED-REGISTRY.yaml", "Master list of protected patterns"),
        ("LOCKED/GIT-WORKTREE.md", "Multi-agent isolation strategy"),
        ("LOCKED/8-GATE-SYSTEM.md", "Quality gate sequence"),
    ]
    
    for path, desc in locked_docs:
        content += f"- [{path}]({SITE_URL}/docs/{path}): {desc}\n"
    
    content += "\n## Claude Context\n\n"
    content += f"- [CONTEXT-PRIMER.md]({SITE_URL}/docs/claude-context/CONTEXT-PRIMER.md): Quick orientation for new sessions\n"
    content += f"- [CHANGE-PROTOCOL.md]({SITE_URL}/docs/claude-context/CHANGE-PROTOCOL.md): How to handle change requests\n"
    
    content += f"\n## Full Content\n\n"
    content += f"- [llms-full.txt]({SITE_URL}/llms-full.txt): All documentation in single file\n"
    
    return content

def generate_llms_full_txt():
    """Combine all markdown files into single file"""
    
    content = "# Eli's Multi-Agent Development Methodology - Full Content\n\n"
    content += "This file contains all methodology documentation for full context.\n\n"
    content += "=" * 80 + "\n\n"
    
    # Walk through docs directory
    for md_file in sorted(DOCS_DIR.rglob("*.md")):
        relative_path = md_file.relative_to(DOCS_DIR)
        content += f"## FILE: {relative_path}\n\n"
        content += md_file.read_text()
        content += "\n\n" + "=" * 80 + "\n\n"
    
    # Also include yaml files
    for yaml_file in sorted(DOCS_DIR.rglob("*.yaml")):
        relative_path = yaml_file.relative_to(DOCS_DIR)
        content += f"## FILE: {relative_path}\n\n"
        content += "```yaml\n"
        content += yaml_file.read_text()
        content += "\n```\n\n" + "=" * 80 + "\n\n"
    
    return content

if __name__ == "__main__":
    # Generate files
    Path("llms.txt").write_text(generate_llms_txt())
    Path("llms-full.txt").write_text(generate_llms_full_txt())
    
    print("✅ Generated llms.txt")
    print("✅ Generated llms-full.txt")
```

#### Step 6: GitHub Actions for Auto-Deploy

```yaml
# .github/workflows/deploy.yml
name: Deploy Methodology Site

on:
  push:
    branches: [main]

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: 3.x
      
      - name: Install dependencies
        run: |
          pip install mkdocs-material
      
      - name: Generate llms.txt files
        run: python scripts/generate-llms-txt.py
      
      - name: Deploy to GitHub Pages
        run: mkdocs gh-deploy --force
```

#### Step 7: Enable GitHub Pages

1. Go to repo Settings → Pages
2. Source: Deploy from branch
3. Branch: gh-pages
4. Save

**Your site will be live at:** `https://YOUR_USERNAME.github.io/eli-methodology`

---

## How Claude.ai Accesses Your Site

### Method 1: Direct URL Fetch

When you mention a URL, I can fetch it:

```
You: "Check my methodology at https://eli-methodology.github.io/llms.txt"

Claude: [fetches URL] → Reads your llms.txt → Understands structure
```

### Method 2: Web Search

I can search for your site:

```
You: "Search for my multi-agent methodology"

Claude: [web search] → Finds your site → Fetches relevant pages
```

### Method 3: Reference in Conversation

Add to your Claude.ai Project instructions:

```markdown
## My Methodology Site

My methodology documentation is available at:
https://eli-methodology.github.io

Key URLs:
- Overview: https://eli-methodology.github.io/llms.txt
- Full content: https://eli-methodology.github.io/llms-full.txt

When I ask about methodology patterns:
1. Fetch the llms.txt to understand structure
2. Fetch specific docs as needed
3. Check LOCKED-REGISTRY before suggesting changes
```

---

## Security Considerations

### Public vs Private

| Option | Claude Access | Security |
|--------|---------------|----------|
| **Public GitHub Pages** | ✅ Full access | Anyone can view |
| **Private repo + Netlify** | ✅ With auth token | Password protected |
| **Cloudflare Access** | ✅ With headers | Zero-trust security |

### For Sensitive Content

If your methodology contains sensitive information:

#### Option A: Netlify with Password

```toml
# netlify.toml
[[headers]]
  for = "/*"
  [headers.values]
    Basic-Auth = "eli:your-password"
```

Then tell Claude the password in conversation (won't work for web fetch).

#### Option B: Split Public/Private

```
PUBLIC SITE (GitHub Pages):
├── Core patterns (safe to share)
├── General workflows
└── Public documentation

PRIVATE (Claude Project uploads):
├── API keys references
├── Client-specific configs
└── Proprietary implementations
```

#### Option C: Cloudflare Access

- Zero-trust authentication
- Can whitelist specific IPs
- More complex setup

**Recommendation:** For methodology docs, public GitHub Pages is fine. Keep credentials and client-specific info in Claude Project uploads.

---

## Complete Workflow

### Initial Setup (One Time)

```bash
# 1. Create repo
gh repo create eli-methodology --public
cd eli-methodology

# 2. Set up MkDocs
pip install mkdocs-material
mkdocs new .

# 3. Copy your methodology docs to docs/

# 4. Configure mkdocs.yml

# 5. Create llms.txt generator script

# 6. Add GitHub Actions workflow

# 7. Push
git add .
git commit -m "Initial methodology site"
git push

# 8. Enable GitHub Pages in repo settings
```

### Ongoing Updates

```bash
# When you update methodology:

# 1. Edit markdown files in docs/
vim docs/core/WORKFLOW-V10.md

# 2. Regenerate llms.txt (or let CI do it)
python scripts/generate-llms-txt.py

# 3. Push
git add .
git commit -m "Update workflow v10.0.7"
git push

# GitHub Actions auto-deploys
# Site updates in ~2 minutes
```

### In Claude.ai Conversations

```
You: "Check my methodology at https://eli-methodology.github.io/llms.txt 
     and help me add a new validation rule"

Claude: [fetches llms.txt]
        [sees structure, finds PM-VALIDATOR.md]
        [fetches PM-VALIDATOR.md]
        [checks LOCKED-REGISTRY.yaml]
        
        "I found your PM Validator v5.5 pattern. The validation 
         patterns are NOT locked, so I can help extend them. 
         Based on your existing validation structure..."
```

---

## Alternative Solutions

### Mintlify (Easiest)

- Auto-generates llms.txt
- Beautiful docs UI
- Git sync
- Free tier available

```bash
npx mintlify@latest init
```

### GitBook

- Visual editor
- Git sync
- Free for public docs

### Docsify

- Zero build step
- GitHub Pages compatible
- Lightweight

---

## Summary: Recommended Approach

| Component | Solution | Why |
|-----------|----------|-----|
| **Hosting** | GitHub Pages | Free, version controlled |
| **Generator** | MkDocs Material | Beautiful, search, easy |
| **AI Access** | llms.txt | Standard, Claude understands |
| **Updates** | GitHub Actions | Auto-deploy on push |
| **Security** | Public (methodology) | Docs aren't sensitive |

### Quick Start

1. Create GitHub repo
2. Add your markdown docs
3. Add llms.txt at root
4. Enable GitHub Pages
5. Reference URL in Claude conversations

**Result:** Claude can fetch your methodology anytime you reference the URL.

---

## Next Steps

Would you like me to:

1. **Create the complete MkDocs structure** with your existing methodology?
2. **Generate the llms.txt file** based on your current project knowledge?
3. **Set up the GitHub Actions workflow** for auto-deployment?
4. **Create the LOCKED-REGISTRY.yaml** with your validated patterns?
