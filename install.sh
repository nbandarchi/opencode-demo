#!/bin/bash

# OpenCode Startup Guide Installation Script
# This script installs OpenCode and sets up the development environment

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"

print_header "OpenCode Startup Guide Installation"

# Check prerequisites
print_info "Checking prerequisites..."

if ! command_exists npm; then
    print_error "npm is not installed. Please install Node.js and npm first."
    print_info "Visit https://nodejs.org/ to download Node.js"
    exit 1
fi

print_success "npm is installed"

# Check if OpenCode is already installed
if command_exists opencode; then
    print_warning "OpenCode is already installed"
    read -p "Do you want to reinstall/update OpenCode? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping OpenCode installation"
    else
        INSTALL_OPENCODE=true
    fi
else
    INSTALL_OPENCODE=true
fi

# Install OpenCode if needed
if [ "$INSTALL_OPENCODE" = true ]; then
    print_info "Installing OpenCode..."
    npm install -g opencode-ai@latest
    print_success "OpenCode installed successfully"
fi

# Create ~/.secrets directory
print_info "Setting up secrets directory..."
SECRETS_DIR="$HOME/.secrets"
if [ ! -d "$SECRETS_DIR" ]; then
    mkdir -p "$SECRETS_DIR"
    chmod 700 "$SECRETS_DIR"
    print_success "Created ~/.secrets directory"
else
    print_success "~/.secrets directory already exists"
fi

# Create local secrets directory if it doesn't exist
LOCAL_SECRETS_DIR="$REPO_DIR/secrets"
if [ ! -d "$LOCAL_SECRETS_DIR" ]; then
    mkdir -p "$LOCAL_SECRETS_DIR"
    print_success "Created local secrets directory"
else
    print_success "Local secrets directory already exists"
fi

# Create symlink from ~/.secrets to repo secrets
SYMLINK_PATH="$SECRETS_DIR/opencode"
if [ -L "$SYMLINK_PATH" ]; then
    print_success "Symlink already exists"
elif [ -e "$SYMLINK_PATH" ]; then
    print_error "Symlink path exists but is not a symlink: $SYMLINK_PATH"
    exit 1
else
    ln -s "$LOCAL_SECRETS_DIR" "$SYMLINK_PATH"
    print_success "Created symlink: ~/.secrets/opencode -> $LOCAL_SECRETS_DIR"
fi

# Prompt for Context7 API key
print_header "Context7 API Key Setup"
print_info "Context7 provides up-to-date code documentation for AI coding assistants"
print_info "Sign up for a free account at: https://context7.com/dashboard"
echo

read -p "Do you have a Context7 API key? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    while true; do
        read -p "Enter your Context7 API key (or press Enter to skip): " -s API_KEY
        echo
        if [ -z "$API_KEY" ]; then
            print_warning "No API key provided - you can add it later"
            break
        elif [ ${#API_KEY} -lt 10 ]; then
            print_error "API key seems too short. Please try again."
        else
            break
        fi
    done
else
    print_info "Skipping API key setup - you can add it later"
    print_info "To add it later, edit: $LOCAL_SECRETS_DIR/context7-key"
fi

# Create context7-key file
CONTEXT7_KEY_FILE="$LOCAL_SECRETS_DIR/context7-key"
if [ -n "$API_KEY" ]; then
    echo "$API_KEY" > "$CONTEXT7_KEY_FILE"
    chmod 600 "$CONTEXT7_KEY_FILE"
    print_success "Context7 API key saved to $CONTEXT7_KEY_FILE"
else
    # Create empty file for user to fill later
    touch "$CONTEXT7_KEY_FILE"
    chmod 600 "$CONTEXT7_KEY_FILE"
    print_info "Created empty context7-key file - add your API key later"
fi

# Setup OpenCode configuration
print_header "OpenCode Configuration"

# Create global config directory if it doesn't exist
GLOBAL_CONFIG_DIR="$HOME/.config/opencode"
if [ ! -d "$GLOBAL_CONFIG_DIR" ]; then
    mkdir -p "$GLOBAL_CONFIG_DIR"
    print_success "Created OpenCode config directory"
fi

# Copy our configuration
GLOBAL_CONFIG_FILE="$GLOBAL_CONFIG_DIR/opencode.json"
cp "$REPO_DIR/config/opencode.json" "$GLOBAL_CONFIG_FILE"
print_success "Installed OpenCode configuration"

# Verify installation
print_header "Verification"

if command_exists opencode; then
    OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
    print_success "OpenCode is installed (version: $OPENCODE_VERSION)"
else
    print_error "OpenCode installation verification failed"
    exit 1
fi

if [ -f "$GLOBAL_CONFIG_FILE" ]; then
    print_success "OpenCode configuration is installed"
else
    print_error "OpenCode configuration not found"
    exit 1
fi

if [ -f "$CONTEXT7_KEY_FILE" ]; then
    if [ -s "$CONTEXT7_KEY_FILE" ]; then
        print_success "Context7 API key is configured"
    else
        print_warning "Context7 API key file is empty - add your key to: $CONTEXT7_KEY_FILE"
    fi
else
    print_error "Context7 key file not found"
    exit 1
fi

# Next steps
print_header "Installation Complete!"
print_success "OpenCode and Context7 MCP have been successfully installed"

echo
print_info "Next steps:"
echo "1. Start OpenCode in any project directory: ${YELLOW}opencode${NC}"
echo "2. Use Context7 in your prompts: ${YELLOW}use context7${NC}"
echo "3. Add 'use context7' to get up-to-date documentation"
echo

if [ ! -s "$CONTEXT7_KEY_FILE" ]; then
    print_warning "To get higher rate limits with Context7:"
    echo "  1. Sign up at: https://context7.com/dashboard"
    echo "  2. Add your API key to: $CONTEXT7_KEY_FILE"
    echo
fi

print_info "Configuration files:"
echo "  • Global config: $GLOBAL_CONFIG_FILE"
echo "  • Context7 key: $CONTEXT7_KEY_FILE"
echo "  • Repo config: $REPO_DIR/config/opencode.json"
echo

print_info "For help and documentation:"
echo "  • OpenCode docs: https://opencode.ai/docs"
echo "  • Context7 docs: https://github.com/upstash/context7"
echo "  • This repo: $REPO_DIR"
echo

print_success "Happy coding! 🚀"