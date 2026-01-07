#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# MAF WORKTREE AUTOMATION SCRIPT
# Git Worktree Management for Multi-Agent Development
# ═══════════════════════════════════════════════════════════════════════════════
# Version: 1.0.0
# Date: January 7, 2026
# Purpose: Automate Git worktree creation, management, and cleanup for agents
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# ───────────────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ───────────────────────────────────────────────────────────────────────────────

WORKTREE_BASE="${WORKTREE_BASE:-$HOME/worktrees}"
MAIN_REPO="${MAIN_REPO:-$(pwd)}"
DOMAINS=(auth layout core client pilot project proposal payment deliverables messaging admin notifications)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ───────────────────────────────────────────────────────────────────────────────
# HELPER FUNCTIONS
# ───────────────────────────────────────────────────────────────────────────────

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_help() {
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "  MAF WORKTREE AUTOMATION SCRIPT"
    echo "  Git Worktree Management for Multi-Agent Development"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  setup              Create all worktrees for all agents"
    echo "  create <agent>     Create worktree for specific agent (e.g., fe-auth)"
    echo "  create-story <story-code> <agent>  Create worktree for a story"
    echo "  list               List all active worktrees"
    echo "  status             Show status of all worktrees"
    echo "  cleanup <agent>    Remove worktree for specific agent"
    echo "  cleanup-all        Remove all worktrees (careful!)"
    echo "  sync               Sync all worktrees with main branch"
    echo "  help               Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  WORKTREE_BASE      Base directory for worktrees (default: ~/worktrees)"
    echo "  MAIN_REPO          Main repository path (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0 setup                            # Create all agent worktrees"
    echo "  $0 create fe-auth                   # Create worktree for fe-auth"
    echo "  $0 create-story AUTH-FE-001 fe-auth # Create story-specific worktree"
    echo "  $0 status                           # Show all worktree statuses"
    echo "  $0 cleanup fe-auth                  # Remove fe-auth worktree"
    echo ""
}

# ───────────────────────────────────────────────────────────────────────────────
# CORE FUNCTIONS
# ───────────────────────────────────────────────────────────────────────────────

# Create base worktree directory
setup_base() {
    if [ ! -d "$WORKTREE_BASE" ]; then
        log_info "Creating worktree base directory: $WORKTREE_BASE"
        mkdir -p "$WORKTREE_BASE"
        log_success "Base directory created"
    fi
}

# Create worktree for a specific agent
create_agent_worktree() {
    local agent=$1
    local worktree_path="$WORKTREE_BASE/$agent"
    
    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        log_warning "Worktree already exists: $worktree_path"
        return 0
    fi
    
    # Ensure we're in the main repo
    cd "$MAIN_REPO"
    
    # Create worktree
    log_info "Creating worktree for $agent at $worktree_path"
    git worktree add "$worktree_path" -b "agent/$agent" main 2>/dev/null || \
    git worktree add "$worktree_path" "agent/$agent" 2>/dev/null || \
    git worktree add "$worktree_path" main
    
    # Create agent-specific CLAUDE.md if template exists
    if [ -f "$MAIN_REPO/templates/CLAUDE.md.template" ]; then
        log_info "Copying CLAUDE.md template for $agent"
        sed "s/{{AGENT_ID}}/$agent/g" "$MAIN_REPO/templates/CLAUDE.md.template" > "$worktree_path/CLAUDE.md"
    fi
    
    # Create .env symlink if not exists
    if [ -f "$MAIN_REPO/.env" ] && [ ! -f "$worktree_path/.env" ]; then
        log_info "Linking .env file"
        ln -s "$MAIN_REPO/.env" "$worktree_path/.env"
    fi
    
    # Create .claude directory for signals
    mkdir -p "$worktree_path/.claude"
    
    log_success "Worktree created for $agent"
}

# Create worktree for a specific story
create_story_worktree() {
    local story_code=$1
    local agent=$2
    local branch_name="feature/$story_code"
    local worktree_path="$WORKTREE_BASE/$agent/$story_code"
    
    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        log_warning "Story worktree already exists: $worktree_path"
        return 0
    fi
    
    # Ensure we're in the main repo
    cd "$MAIN_REPO"
    
    # Create worktree with feature branch
    log_info "Creating story worktree for $story_code ($agent)"
    mkdir -p "$WORKTREE_BASE/$agent"
    git worktree add "$worktree_path" -b "$branch_name" main 2>/dev/null || \
    git worktree add "$worktree_path" "$branch_name"
    
    # Copy templates
    if [ -f "$MAIN_REPO/templates/START.md.template" ]; then
        cp "$MAIN_REPO/templates/START.md.template" "$worktree_path/START.md"
        sed -i "s/{{STORY_CODE}}/$story_code/g" "$worktree_path/START.md" 2>/dev/null || \
        sed -i '' "s/{{STORY_CODE}}/$story_code/g" "$worktree_path/START.md"
    fi
    
    if [ -f "$MAIN_REPO/templates/ROLLBACK-PLAN.md.template" ]; then
        cp "$MAIN_REPO/templates/ROLLBACK-PLAN.md.template" "$worktree_path/ROLLBACK-PLAN.md"
        sed -i "s/{{STORY_CODE}}/$story_code/g" "$worktree_path/ROLLBACK-PLAN.md" 2>/dev/null || \
        sed -i '' "s/{{STORY_CODE}}/$story_code/g" "$worktree_path/ROLLBACK-PLAN.md"
    fi
    
    # Link .env
    if [ -f "$MAIN_REPO/.env" ] && [ ! -f "$worktree_path/.env" ]; then
        ln -s "$MAIN_REPO/.env" "$worktree_path/.env"
    fi
    
    log_success "Story worktree created: $worktree_path (branch: $branch_name)"
    echo ""
    echo "To start working:"
    echo "  cd $worktree_path"
    echo "  claude -p 'Read CLAUDE.md and START.md, then begin Gate 1'"
}

# Setup all worktrees for standard agent configuration
setup_all_worktrees() {
    log_info "Setting up worktrees for all agents..."
    echo ""
    
    setup_base
    
    # Management agents (work in main repo, no worktree needed)
    log_info "CTO and PM agents work in main repository"
    
    # Frontend agents
    for domain in "${DOMAINS[@]}"; do
        create_agent_worktree "fe-$domain"
    done
    
    # Backend agents
    for domain in "${DOMAINS[@]}"; do
        create_agent_worktree "be-$domain"
    done
    
    # QA agents (specialized)
    create_agent_worktree "qa-core"
    create_agent_worktree "qa-auth"
    create_agent_worktree "qa-transactions"
    create_agent_worktree "qa-comms"
    create_agent_worktree "qa-integration"
    
    echo ""
    log_success "All worktrees created!"
    echo ""
    list_worktrees
}

# List all worktrees
list_worktrees() {
    log_info "Active worktrees:"
    echo ""
    cd "$MAIN_REPO"
    git worktree list
    echo ""
}

# Show status of all worktrees
show_status() {
    log_info "Worktree status:"
    echo ""
    
    cd "$MAIN_REPO"
    
    for worktree in $(git worktree list --porcelain | grep "worktree " | cut -d' ' -f2); do
        if [ "$worktree" = "$MAIN_REPO" ]; then
            continue
        fi
        
        agent=$(basename "$worktree")
        branch=$(cd "$worktree" && git branch --show-current 2>/dev/null || echo "unknown")
        changes=$(cd "$worktree" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        
        if [ "$changes" -gt 0 ]; then
            echo -e "${YELLOW}⚡ $agent${NC} (branch: $branch, $changes uncommitted changes)"
        else
            echo -e "${GREEN}✓ $agent${NC} (branch: $branch, clean)"
        fi
    done
    
    echo ""
}

# Cleanup specific worktree
cleanup_worktree() {
    local agent=$1
    local worktree_path="$WORKTREE_BASE/$agent"
    
    if [ ! -d "$worktree_path" ]; then
        log_warning "Worktree not found: $worktree_path"
        return 0
    fi
    
    # Check for uncommitted changes
    cd "$worktree_path"
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        log_error "Worktree has uncommitted changes! Commit or stash first."
        log_info "Run: cd $worktree_path && git stash"
        return 1
    fi
    
    cd "$MAIN_REPO"
    
    log_info "Removing worktree for $agent"
    git worktree remove "$worktree_path" --force
    
    # Remove branch if it was agent-specific
    git branch -d "agent/$agent" 2>/dev/null || true
    
    log_success "Worktree removed: $agent"
}

# Cleanup all worktrees
cleanup_all_worktrees() {
    log_warning "This will remove ALL worktrees!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "Aborted"
        return 0
    fi
    
    cd "$MAIN_REPO"
    
    for worktree in $(git worktree list --porcelain | grep "worktree " | cut -d' ' -f2); do
        if [ "$worktree" = "$MAIN_REPO" ]; then
            continue
        fi
        
        log_info "Removing: $worktree"
        git worktree remove "$worktree" --force 2>/dev/null || true
    done
    
    # Prune stale worktree references
    git worktree prune
    
    log_success "All worktrees removed"
}

# Sync all worktrees with main
sync_worktrees() {
    log_info "Syncing all worktrees with main branch..."
    echo ""
    
    cd "$MAIN_REPO"
    
    # First, update main
    log_info "Updating main branch..."
    git checkout main
    git pull origin main
    
    # Then sync each worktree
    for worktree in $(git worktree list --porcelain | grep "worktree " | cut -d' ' -f2); do
        if [ "$worktree" = "$MAIN_REPO" ]; then
            continue
        fi
        
        agent=$(basename "$worktree")
        log_info "Syncing $agent..."
        
        cd "$worktree"
        
        # Stash any changes
        git stash 2>/dev/null || true
        
        # Rebase on main
        git fetch origin main
        git rebase origin/main 2>/dev/null || {
            log_warning "Rebase conflict in $agent - manual resolution needed"
            git rebase --abort 2>/dev/null || true
        }
        
        # Restore stash
        git stash pop 2>/dev/null || true
        
        cd "$MAIN_REPO"
    done
    
    log_success "Sync complete"
}

# ───────────────────────────────────────────────────────────────────────────────
# MAIN COMMAND ROUTER
# ───────────────────────────────────────────────────────────────────────────────

case "${1:-}" in
    setup)
        setup_all_worktrees
        ;;
    create)
        if [ -z "${2:-}" ]; then
            log_error "Agent name required"
            echo "Usage: $0 create <agent>"
            exit 1
        fi
        setup_base
        create_agent_worktree "$2"
        ;;
    create-story)
        if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
            log_error "Story code and agent required"
            echo "Usage: $0 create-story <story-code> <agent>"
            exit 1
        fi
        setup_base
        create_story_worktree "$2" "$3"
        ;;
    list)
        list_worktrees
        ;;
    status)
        show_status
        ;;
    cleanup)
        if [ -z "${2:-}" ]; then
            log_error "Agent name required"
            echo "Usage: $0 cleanup <agent>"
            exit 1
        fi
        cleanup_worktree "$2"
        ;;
    cleanup-all)
        cleanup_all_worktrees
        ;;
    sync)
        sync_worktrees
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
