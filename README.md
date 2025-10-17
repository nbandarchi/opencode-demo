# OpenCode Startup Guide

Welcome to the OpenCode startup guide! This repository will help you get started with OpenCode as a powerful coding assistant and set up essential tools like Context7 MCP.

## What is OpenCode?

OpenCode is an interactive CLI tool that helps developers with software engineering tasks. It provides intelligent code assistance, file management, and integration with various development tools.

## Quick Start

### Automated Installation (Recommended)

The easiest way to get started is to run our installation script:

```bash
./install.sh
```

This script will:
- ✅ Install OpenCode globally
- ✅ Set up secure configuration
- ✅ Configure Context7 MCP for up-to-date documentation
- ✅ Prompt for your Context7 API key (optional)
- ✅ Create necessary directories and symlinks
- ✅ Verify the installation

### Manual Installation

If you prefer to install manually, follow these steps:

#### Prerequisites

- Node.js (version 16 or higher)
- npm or yarn package manager

#### Install OpenCode

```bash
npm install -g opencode-ai@latest
```

#### Verify Installation

```bash
opencode --version
```

#### Setup Configuration

```bash
# Create the global config directory if it doesn't exist
mkdir -p ~/.config/opencode

# Copy the base configuration
cp config/opencode.json ~/.config/opencode/opencode.json
```

#### Setup Context7 API Key (Optional)

For higher rate limits with Context7:

```bash
# Create secrets directory
mkdir -p secrets

# Create your API key file
echo "your_api_key_here" > secrets/context7-key
chmod 600 secrets/context7-key
```

## Getting Started

Once installed, you can start using OpenCode in any project directory:

```bash
cd your-project
opencode
```

## Context7 MCP Setup

Context7 MCP provides up-to-date code documentation for LLMs and AI code editors. It pulls current, version-specific documentation and code examples directly from the source.

### Installation

You can install Context7 MCP either as a remote server (recommended) or locally:

#### Option 1: Remote Server (Recommended)

Add this to your `opencode.json` configuration file:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

#### Option 2: With API Key (Higher Rate Limits)

If you sign up for a free account at [context7.com/dashboard](https://context7.com/dashboard), you can get higher rate limits:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
      }
    }
  }
}
```

Set the environment variable:

```bash
export CONTEXT7_API_KEY=your_api_key_here
```

#### Option 3: Local Server

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Usage

Add `use context7` to your prompts to automatically fetch up-to-date documentation:

```
Create a Next.js middleware that checks for a valid JWT in cookies and redirects unauthenticated users to /login. use context7
```

### Available Tools

Context7 MCP provides these tools:

- `resolve-library-id`: Find the correct Context7 library ID
- `get-library-docs`: Fetch documentation for a specific library

### Pro Tip

Add this to your `AGENTS.md` file to automatically use Context7 when needed:

```
When you need code generation, setup steps, or library/API documentation, automatically use Context7 MCP tools to resolve library id and get library docs.
```

## Basic Usage

### Common OpenCode Commands

- `/help` - Get help with using OpenCode
- `opencode` - Start OpenCode in current directory
- Use natural language to request code changes, file operations, or explanations

### Example Commands

```
"Create a new React component for user profiles"
"Refactor this function to be more efficient"
"Add tests for the authentication service"
"Explain how this algorithm works"
```

## Configuration

### What Gets Configured

The installation sets up a secure OpenCode configuration with:

- **🔒 Safe Permissions**: Set to "ask" for `edit`, `bash`, and `webfetch` operations
- **📚 Context7 MCP**: Pre-configured for up-to-date code documentation
- **📋 Instructions**: Includes this README and AGENTS.md for context
- **🎨 Theme**: Uses the default "opencode" theme
- **🔄 Autoupdate**: Enabled to keep OpenCode current

### Security Features

- **🔐 Secure Storage**: API keys stored in restricted files (chmod 600)
- **🔗 Symlinked Secrets**: `~/.secrets/opencode-demo` → `./secrets/`
- **🚫 Git-Safe**: Secret files excluded from version control
- **📁 Isolated Configuration**: Separate from project files

### File Structure

After installation, you'll have:

```
opencode-demo/
├── secrets/
│   └── context7-key     # Your API key (gitignored)
├── config/
│   └── opencode.json    # Configuration template
└── install.sh           # Installation script

~/.config/opencode/
└── opencode.json        # Your active configuration

~/.secrets/
└── opencode-demo/       # Symlink to repo secrets/
    └── context7-key
```

### Context7 API Key

**Free Tier**: Works without an API key with standard rate limits

**Higher Limits**: Sign up at [context7.com/dashboard](https://context7.com/dashboard) for:
- Increased rate limits
- Access to private repositories
- Better performance

The installation script will prompt you for an API key, or you can add it later to:
```bash
secrets/context7-key
```

## Next Steps

1. **Run the installer**: `./install.sh` (if you haven't already)
2. **Try it out**: Start OpenCode in any project with `opencode`
3. **Test Context7**: Add `use context7` to your prompts for up-to-date docs
4. **Explore examples**: Check the [examples](./examples/) directory for common use cases
5. **Read guides**: Browse the [guides](./guides/) directory for detailed tutorials
6. **Configure IDE**: Set up your preferred editor extensions for better integration

### Example Usage

```bash
# Start OpenCode
opencode

# Try Context7 integration
"Create a Next.js middleware that checks for a valid JWT in cookies and redirects unauthenticated users to /login. use context7"

# Use custom commands
/summarize

# Get help
/help
```

### Managing Commands and Agents

This repository includes custom commands and agents that can be synced to OpenCode:

```bash
# Sync local commands to OpenCode
./sync.sh

# Sync local agents to OpenCode
./sync-agents.sh

# Available commands will be listed after sync
# Use them with: /command-name

# Available agents will be listed after sync  
# Use them with: @agent-name
```

#### Example Usage

```bash
# Start OpenCode
opencode

# Use the summarize command
/summarize

# Use the ELI5 agent
@ELI5 How does machine learning work?

# Try Context7 integration
"Create a Next.js middleware that checks for a valid JWT in cookies and redirects unauthenticated users to /login. use context7"

# Get help
/help
```

### Troubleshooting

If you encounter issues:

1. **Check installation**: `opencode --version`
2. **Verify config**: `cat ~/.config/opencode/opencode.json`
3. **Test API key**: Ensure `secrets/context7-key` contains your key (optional)
4. **Reinstall**: Run `./install.sh` again

For more help, see:
- [OpenCode Documentation](https://opencode.ai/docs)
- [Context7 Documentation](https://github.com/upstash/context7)
- [Open Issues](https://github.com/sst/opencode/issues)

## Support

- Report issues at: https://github.com/sst/opencode/issues
- Documentation: https://opencode.ai
- Community: Join our Discord server

## Contributing

We welcome contributions! Please see our [contributing guidelines](./CONTRIBUTING.md) for more information.
