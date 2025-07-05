# Code Formatting Guidelines for LLMs

This document provides formatting guidelines for LLMs working with code in this
repository. All code should be formatted according to these standards before
being presented to users.

## Formatting Tools by Language

Based on the conform.nvim configuration, the following formatters are used:

### Shell Scripts (sh, bash, zsh)

- **shfmt**: 2-space indentation with simplified syntax
  - Use `-i 2 -s` options
  - Maximum line length: 80 characters
- **shellharden**: Improve shell script robustness
- **shellcheck**: Static analysis for shell scripts
  - Use `--shell=bash` for consistency

### Lua

- **stylua**: Standard Lua formatter

### Python

- **isort**: Import sorting
- **black**: Code formatting

### JavaScript

- **prettierd** or **prettier**: Code formatting

### Markdown

- **markdownlint**: Linting for markdown files
- **mdformat**: Formatting with `--number` option for numbered lists

### JSON

- **fixjson**: JSON formatting and fixing

### YAML

- **yamlfmt**: YAML formatting

### SQL

- **sql_formatter**: SQL code formatting

### Terraform

- **terraform_fmt**: Terraform formatting

### TOML

- **taplo**: TOML formatting

### Dockerfile

- **dprint**: Dockerfile formatting

### All Files

- **codespell**: Spell checking with specific built-in dictionaries:
  - clear, rare, informal, usage, names

## Formatting Rules

### Shell Scripts

- Use 2-space indentation consistently
- Keep lines to 80 characters maximum
- Use simplified syntax where possible
- Follow bash conventions even for other shells
- Include proper error handling with `set -eEuo pipefail`

### Markdown

- Use numbered lists where appropriate
- Keep lines to 80 characters maximum
- Follow standard markdown formatting

### General Guidelines

- Apply spell checking to all text content
- Use consistent indentation per language
- Maintain readability and adherence to language conventions
- Follow the principle of least surprise

## Implementation Notes

When generating code:

1. Format according to the language-specific rules above
2. Run spell checking on comments and documentation
3. Ensure proper indentation and line length limits
4. Use the most appropriate formatter for each file type
5. Consider that multiple formatters may run sequentially for some
   languages

## Custom Configurations

### mdformat

- Uses `--number` flag for numbered lists

### shellcheck

- Uses `--shell=bash` for consistency across shell types

### shfmt

- Uses `-i 2 -s` for 2-space indentation and simplified syntax

### codespell

- Includes hidden files in checking
- Uses comprehensive built-in dictionaries
- Respects local `.codespell` ignore files if present
