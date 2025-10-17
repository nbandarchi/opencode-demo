#!/bin/bash

# OpenCode Agents Sync Script
# This script syncs local agents to the global OpenCode agents directory

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
LOCAL_AGENTS_DIR="$REPO_DIR/agents"
GLOBAL_AGENTS_DIR="$HOME/.config/opencode/agent"

print_header "OpenCode Agents Sync"

# Check if local agents directory exists
if [ ! -d "$LOCAL_AGENTS_DIR" ]; then
    print_error "Local agents directory not found: $LOCAL_AGENTS_DIR"
    exit 1
fi

print_success "Found local agents directory: $LOCAL_AGENTS_DIR"

# Create global agents directory if it doesn't exist
if [ ! -d "$GLOBAL_AGENTS_DIR" ]; then
    print_info "Creating global agents directory..."
    mkdir -p "$GLOBAL_AGENTS_DIR"
    print_success "Created: $GLOBAL_AGENTS_DIR"
else
    print_success "Global agents directory exists: $GLOBAL_AGENTS_DIR"
fi

# Sync agents
print_info "Syncing agents..."

# Count agents to sync
AGENT_COUNT=$(find "$LOCAL_AGENTS_DIR" -name "*.md" -type f | wc -l)
if [ "$AGENT_COUNT" -eq 0 ]; then
    print_warning "No markdown agents found in $LOCAL_AGENTS_DIR"
    exit 0
fi

print_info "Found $AGENT_COUNT agent(s) to sync"

# Copy each agent file
for agent_file in "$LOCAL_AGENTS_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file" .md)
        target_file="$GLOBAL_AGENTS_DIR/$agent_name.md"
        
        # Copy the agent file
        cp "$agent_file" "$target_file"
        print_success "Synced agent: $agent_name"
    fi
done

# Verify sync
print_header "Verification"
SYNCED_COUNT=$(find "$GLOBAL_AGENTS_DIR" -name "*.md" -type f | wc -l)
print_success "Synced $AGENT_COUNT agent(s) to global directory"
print_info "Global agents directory now contains $SYNCED_COUNT agent(s)"

# List synced agents
echo
print_info "Synced agents:"
for agent_file in "$GLOBAL_AGENTS_DIR"/*.md; do
    if [ -f "$agent_file" ]; then
        agent_name=$(basename "$agent_file" .md)
        # Extract description from frontmatter if available
        description=$(grep -m1 "^description:" "$agent_file" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "No description")
        
        # Extract model if available
        model=$(grep -m1 "^model:" "$agent_file" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "default")
        
        echo "  • ${GREEN}$agent_name${NC}: $description (${YELLOW}model: $model${NC})"
    fi
done

echo
print_success "Agents sync completed!"
print_info "You can now use these agents in OpenCode with: @agent-name"
print_info "Example: @ELI5 How does the internet work?"