# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

This is a comprehensive personal development environment configuration
repository (dotfiles) that supports cross-platform development with a focus on
Perl, Go, and shell scripting. The setup is optimised for terminal-based
workflows using Neovim, tmux, and zsh.

## Key Commands

### System Setup and Maintenance

```bash
# Initial system setup on linux
./SETUP

# Update existing installation
. ./UPDATE

# Complete system rebuild (updates packages, plugins, dependencies)
utils/full_build

# Build all external repositories managed via ghq
utils/build_all

# Build individual software components
utils/build <component>
```

### Development Tools

```bash
# Perl code linting
utils/lint_perl

# Neovim configuration is managed via lazy.nvim
# Plugins auto-install on startup
```

## Architecture and Structure

### Core Configuration Layout

- `.config/nvim/` - Neovim configuration with Lua-based plugins
  - `lua/plugins.lua` - Plugin management with lazy.nvim
  - `lua/mappings.lua` - Key bindings and which-key setup
  - `lua/lsp.lua` - Language Server Protocol configuration
  - `ftplugin/` - File type specific configurations
- `utils/` - Build scripts and system utilities
- `zsh/` - Shell configuration and completions
- `templates/` - File templates (Perl modules, programs, tests)

### Development Environment

- **Primary Languages**: Perl (main), Go (secondary), shell scripting
- **Editor**: Neovim with AI integration (Copilot, Codeium, Supermaven)
- **Terminal**: Terminal-centric workflow with tmux multiplexing
- **Shell**: Zsh with zinit plugin management
- **Theme**: Solarized Dark applied consistently across all tools

### Plugin Management

- **Neovim**: lazy.nvim for plugin management with AI completion support
- **Shell**: zinit for zsh plugin management
- **System**: Brewfile for package management across platforms

### Cross-Platform Support

- **macOS** (primary): Full Brewfile with GUI applications
- **Linux**: Platform-specific Brewfiles for different distributions
- **WSL**: Windows Subsystem for Linux support
- **FreeBSD**: pkg-based package management

## Important Notes

### Build System

- `utils/full_build` is the master build script for complete system setup
- On Linux, external repositories are managed via ghq (listed in `ghq.repos`)
- Package dependencies are defined in platform-specific Brewfiles

### Neovim Configuration

- Uses lazy.nvim for plugin management with automatic installation
- Comprehensive LSP setup with Mason for language server management
- Multiple AI completion providers configured simultaneously
- Treesitter for enhanced syntax highlighting and code navigation

### Development Workflow

- Optimised for terminal-based development with extensive tmux integration
- Custom Perl linting available via `utils/lint_perl`
- Git integration with advanced aliases and tooling
- File templates available in `templates/` directory for common Perl patterns

When working with this repository, focus on the `utils/` directory for build
scripts and `.config/nvim/lua/` for editor configuration modifications.
