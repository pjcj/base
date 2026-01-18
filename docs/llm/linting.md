# Code Linting Guidelines for LLMs

This document provides linting guidelines for LLMs working with code in this
repository. All code should adhere to these linting standards to maintain
quality and consistency.

## Linting Tools by Language

Based on the nvim-lint and LSP configurations, the following linters are used:

### Perl

- **perlcritic**: Comprehensive Perl static analysis (severity level 2)
- **perlimports**: Import management and validation
- **perlnavigator**: LSP-based analysis via Perl Navigator

### Shell Scripts (sh, bash, zsh)

- **shellcheck**: Static analysis for shell scripts with `--shell=bash`
- **zsh**: Zsh-specific linting for zsh scripts

### JavaScript

- **eslint**: JavaScript/TypeScript linting

### Markup and Data Formats

- **markdownlint**: Markdown file linting
- **jsonlint**: JSON validation and linting
- **yamllint**: YAML file linting
- **rstlint**: reStructuredText linting
- **tidy**: HTML validation and linting

### Specialised Tools

- **spectral**: OpenAPI/AsyncAPI specification linting (YAML files)
- **codespell**: Spell checking with built-in dictionaries
- **typos**: Additional typo detection

## Perl Linting Rules (Perlcritic)

### Core Configuration

- **Severity level**: 2 (allows most policies except cosmetic)
- **Verbose output**: Level 8 (full policy names and explanations)
- **Allow unsafe operations**: Enabled
- **Colour coding**: Severity-based colour output

### Key Policies Enforced

#### Code Structure

- Use 2-space indentation consistently
- Prohibit hard tabs (use spaces)
- Require trailing commas in multi-line lists
- Prohibit trailing whitespace
- Require consistent newlines throughout source

#### Best Practices

- Always use `strict` and `warnings`
- Use `parent` instead of `@ISA`
- Use lexical file handles (`open my $fh`)
- Check return values of system calls
- Use proper error handling with `eval` blocks

#### Moose-Specific Rules

- Use `DEMOLISH` instead of `DESTROY`
- Require `make_immutable` for performance
- Require clean namespaces
- Prohibit multiple `with` statements (use role composition)
- Prohibit custom `new` methods

#### Complexity Management

- Maximum cyclomatic complexity: 20 (subroutines)
- Maximum main complexity: 3 (outside subroutines)
- Maximum subroutine arguments: 5 (excluding `$self`/`$class`)
- Maximum elsif chains: 10
- Prohibit deeply nested structures

#### Security and Performance

- Use 3-argument `open`
- Require UTF-8 encoding specification
- Avoid performance-impacting variables (`$&`, `$``, `$'`)
- Use `local` for magic variables

### Disabled Policies

These policies are intentionally disabled:

- Block-style `grep` and `map` (allow expression style)
- Postfix controls (allow `do_something if $condition`)
- Unless/until blocks (allow their use)
- C-style for loops (allow for complex cases)
- Hard requirements for POD sections

## LSP-Based Linting

### Perl Navigator Configuration

- **Perlcritic integration**: Automatic if `.perlcriticrc` exists
- **Perlimports support**: Automatic if `.perlimports.toml` exists
- **Custom include paths**: Dynamically determined
- **Debounce delay**: Dynamic based on file size (2ms per line, min 500ms, max 60s)

### Diagnostic Filtering

The LSP configuration filters out known false positives:

- "Useless use of a constant" at end of files
- False "Subroutine redefined" warnings
- Devel::Cover internal function warnings
- Bash language server workspace warnings

### Other Language Servers

- **bashls**: Shell script analysis with zsh support
- **eslint**: JavaScript linting via LSP
- **yamlls**: YAML validation with schema support
- **jsonls**: JSON validation and formatting
- **gopls**: Go language analysis with hints enabled

## Real-Time Linting

### Auto-Linting Events

Linting runs automatically on:

- `BufEnter`: When entering a buffer
- `BufReadPost`: After reading a file
- `BufWritePost`: After saving a file
- `CursorHold`: When cursor is idle

### Universal Checks

These run on all file types:

- **codespell**: Spell checking with custom dictionaries
- **typos**: Additional typo detection

### Configuration Files

- `.perlcriticrc`: Perlcritic rules and severity settings
- `.perlimports.toml`: Perlimports configuration
- `.codespell`: Project-specific spell check ignore list

## Language-Specific Guidelines

### Perl Code Quality

- Follow all Perlcritic severity 2+ policies
- Use modern Perl practices (signatures, postderef)
- Implement proper error handling
- Use Moose/Moo for object-oriented code
- Keep subroutines simple and focused

### Shell Scripts

- Use bash-compatible syntax
- Follow shellcheck recommendations
- Implement proper error handling with `set -euo pipefail`
- Use meaningful variable names
- Quote variables properly

### JavaScript

- Follow ESLint configuration
- Use consistent formatting
- Implement proper error handling
- Use modern ES6+ features appropriately

### Markup and Data

- Validate all JSON and YAML syntax
- Follow markdown best practices
- Use consistent formatting in data files
- Validate OpenAPI specifications with Spectral

## Integration Notes

### ALE Configuration

- Uses Neovim's native diagnostics API
- Virtual text cursor display enabled
- Most language-specific linters disabled in favour of LSP
- Spectral specifically enabled for YAML files

### Custom Tools

- Spell checking respects `.codespell` ignore files
- Perlcritic and perlimports integrate with editor workflows

### Performance Considerations

- LSP debouncing prevents excessive linting
- Real-time linting balanced with performance
- Diagnostic filtering reduces noise
- Language-specific optimisations applied

## Error Handling

### False Positive Management

The configuration actively filters common false positives while maintaining
strict code quality standards. Custom diagnostic filtering ensures that
legitimate issues are highlighted while reducing noise from known
non-issues.

### Integration Testing

All linting rules are designed to work with the existing codebase and
development workflow. The configuration supports both individual file
linting and project-wide quality assurance.
