#!/bin/bash

# Consolidated Sync Script for OpenCode and Claude Code
# This script syncs local agents and commands to both OpenCode and Claude Code global directories

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
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

print_target() {
    echo -e "${MAGENTA}→ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
LOCAL_AGENTS_DIR="$REPO_DIR/agents"
LOCAL_COMMANDS_DIR="$REPO_DIR/commands"

# Global directories for OpenCode
OPENCODE_AGENTS_DIR="$HOME/.config/opencode/agent"
OPENCODE_COMMANDS_DIR="$HOME/.config/opencode/command"

# Global directories for Claude Code
CLAUDE_AGENTS_DIR="$HOME/.config/claude/agent"
CLAUDE_COMMANDS_DIR="$HOME/.config/claude/command"

# Function to sync files to a target directory
sync_files() {
    local source_dir="$1"
    local target_dir="$2"
    local file_type="$3"
    local app_name="$4"

    # Create target directory if it doesn't exist
    if [ ! -d "$target_dir" ]; then
        print_info "Creating $app_name $file_type directory..."
        mkdir -p "$target_dir"
        print_success "Created: $target_dir"
    else
        print_success "$app_name $file_type directory exists: $target_dir"
    fi

    # Count files to sync
    local file_count=$(find "$source_dir" -name "*.md" -type f | wc -l)
    if [ "$file_count" -eq 0 ]; then
        print_warning "No markdown files found in $source_dir"
        return 0
    fi

    # Copy each file
    local synced=0
    for file in "$source_dir"/*.md; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local target_file="$target_dir/$filename"

            # Backup existing file if it exists (for commands)
            if [ "$file_type" = "commands" ] && [ -f "$target_file" ]; then
                backup_file="$target_file.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$target_file" "$backup_file"
                print_warning "  Backed up existing file"
            fi

            # Copy the file
            cp "$file" "$target_file"
            synced=$((synced + 1))
        fi
    done

    print_success "Synced $synced $file_type to $app_name"
    return 0
}

# Function to list synced files with details
list_synced_files() {
    local target_dir="$1"
    local file_type="$2"

    echo
    print_info "Synced $file_type:"
    for file in "$target_dir"/*.md; do
        if [ -f "$file" ]; then
            local name=$(basename "$file" .md)
            # Extract description from frontmatter if available
            local description=$(grep -m1 "^description:" "$file" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "No description")

            if [ "$file_type" = "agents" ]; then
                # Extract model if available
                local model=$(grep -m1 "^model:" "$file" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "default")
                echo "  • ${GREEN}$name${NC}: $description (${YELLOW}model: $model${NC})"
            else
                echo "  • ${GREEN}$name${NC}: $description"
            fi
        fi
    done
}

# Main execution
print_header "Consolidated Sync: Agents & Commands"

# Check if local directories exist
agents_exist=false
commands_exist=false

if [ -d "$LOCAL_AGENTS_DIR" ]; then
    agents_exist=true
    print_success "Found local agents directory: $LOCAL_AGENTS_DIR"
else
    print_warning "Local agents directory not found: $LOCAL_AGENTS_DIR"
fi

if [ -d "$LOCAL_COMMANDS_DIR" ]; then
    commands_exist=true
    print_success "Found local commands directory: $LOCAL_COMMANDS_DIR"
else
    print_warning "Local commands directory not found: $LOCAL_COMMANDS_DIR"
fi

if [ "$agents_exist" = false ] && [ "$commands_exist" = false ]; then
    print_error "No agents or commands directories found!"
    exit 1
fi

echo

# Sync Agents
if [ "$agents_exist" = true ]; then
    print_header "Syncing Agents"

    # Sync to OpenCode
    print_target "OpenCode: $OPENCODE_AGENTS_DIR"
    sync_files "$LOCAL_AGENTS_DIR" "$OPENCODE_AGENTS_DIR" "agents" "OpenCode"

    echo

    # Sync to Claude Code
    print_target "Claude Code: $CLAUDE_AGENTS_DIR"
    sync_files "$LOCAL_AGENTS_DIR" "$CLAUDE_AGENTS_DIR" "agents" "Claude Code"

    # List synced agents (from OpenCode directory as reference)
    list_synced_files "$OPENCODE_AGENTS_DIR" "agents"

    echo
    print_success "Agents sync completed!"
    print_info "Use in OpenCode with: @agent-name"
    print_info "Use in Claude Code with: @agent-name"
fi

echo

# Sync Commands
if [ "$commands_exist" = true ]; then
    print_header "Syncing Commands"

    # Sync to OpenCode
    print_target "OpenCode: $OPENCODE_COMMANDS_DIR"
    sync_files "$LOCAL_COMMANDS_DIR" "$OPENCODE_COMMANDS_DIR" "commands" "OpenCode"

    echo

    # Sync to Claude Code
    print_target "Claude Code: $CLAUDE_COMMANDS_DIR"
    sync_files "$LOCAL_COMMANDS_DIR" "$CLAUDE_COMMANDS_DIR" "commands" "Claude Code"

    # List synced commands (from OpenCode directory as reference)
    list_synced_files "$OPENCODE_COMMANDS_DIR" "commands"

    echo
    print_success "Commands sync completed!"
    print_info "Use in OpenCode with: /command-name"
    print_info "Use in Claude Code with: /command-name"
fi

echo
print_header "Summary"
print_success "All sync operations completed successfully!"

if [ "$agents_exist" = true ]; then
    agent_count=$(find "$LOCAL_AGENTS_DIR" -name "*.md" -type f | wc -l)
    print_info "Agents synced: $agent_count"
fi

if [ "$commands_exist" = true ]; then
    cmd_count=$(find "$LOCAL_COMMANDS_DIR" -name "*.md" -type f | wc -l)
    print_info "Commands synced: $cmd_count"
fi

echo
print_info "Target applications:"
echo "  • OpenCode: $HOME/.config/opencode/"
echo "  • Claude Code: $HOME/.config/claude/"
