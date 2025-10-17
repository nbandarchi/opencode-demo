#!/bin/bash

# OpenCode Commands Sync Script
# This script syncs local commands to the global OpenCode commands directory

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
LOCAL_COMMANDS_DIR="$REPO_DIR/commands"
GLOBAL_COMMANDS_DIR="$HOME/.config/opencode/command"

print_header "OpenCode Commands Sync"

# Check if local commands directory exists
if [ ! -d "$LOCAL_COMMANDS_DIR" ]; then
    print_error "Local commands directory not found: $LOCAL_COMMANDS_DIR"
    exit 1
fi

print_success "Found local commands directory: $LOCAL_COMMANDS_DIR"

# Create global commands directory if it doesn't exist
if [ ! -d "$GLOBAL_COMMANDS_DIR" ]; then
    print_info "Creating global commands directory..."
    mkdir -p "$GLOBAL_COMMANDS_DIR"
    print_success "Created: $GLOBAL_COMMANDS_DIR"
else
    print_success "Global commands directory exists: $GLOBAL_COMMANDS_DIR"
fi

# Sync commands
print_info "Syncing commands..."

# Count commands to sync
COMMAND_COUNT=$(find "$LOCAL_COMMANDS_DIR" -name "*.md" -type f | wc -l)
if [ "$COMMAND_COUNT" -eq 0 ]; then
    print_warning "No markdown commands found in $LOCAL_COMMANDS_DIR"
    exit 0
fi

print_info "Found $COMMAND_COUNT command(s) to sync"

# Copy each command file
for cmd_file in "$LOCAL_COMMANDS_DIR"/*.md; do
    if [ -f "$cmd_file" ]; then
        cmd_name=$(basename "$cmd_file" .md)
        target_file="$GLOBAL_COMMANDS_DIR/$cmd_name.md"
        
        # Backup existing file if it exists
        if [ -f "$target_file" ]; then
            backup_file="$target_file.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$target_file" "$backup_file"
            print_warning "Backed up existing $cmd_name command to: $backup_file"
        fi
        
        # Copy the command file
        cp "$cmd_file" "$target_file"
        print_success "Synced command: $cmd_name"
    fi
done

# Verify sync
print_header "Verification"
SYNCED_COUNT=$(find "$GLOBAL_COMMANDS_DIR" -name "*.md" -type f | wc -l)
print_success "Synced $COMMAND_COUNT command(s) to global directory"
print_info "Global commands directory now contains $SYNCED_COUNT command(s)"

# List synced commands
echo
print_info "Synced commands:"
for cmd_file in "$GLOBAL_COMMANDS_DIR"/*.md; do
    if [ -f "$cmd_file" ]; then
        cmd_name=$(basename "$cmd_file" .md)
        # Extract description from frontmatter if available
        description=$(grep -m1 "^description:" "$cmd_file" | cut -d':' -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' || echo "No description")
        echo "  • ${GREEN}$cmd_name${NC}: $description"
    fi
done

echo
print_success "Commands sync completed!"
print_info "You can now use these commands in OpenCode with: /<command-name>"
print_info "Example: /summarize"