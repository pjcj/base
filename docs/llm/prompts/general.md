# General coding guidelines

## Rules

### General

All software should adhere to established software engineering principles.
Consider the following:

- **Modularity** Break systems into small, manageable units which can be easily
  understood and tested in isolation
- **Abstraction** Hide internal details and expose only well-defined APIs
- **Encapsulation** Enhance modularity and abstraction by keeping data and
  functions together within the module
- **Strong cohesion** Elements in a module belong together as a cohesive group
- **Loose coupling** Changes to one component should not affect other components
- **Simplicity** Keep modules and functions short and focussed on a single
  responsibility
- **Documentation** Document systems, components and functions - keep code
  sufficiently simple that it rarely needs comments
- **Testing** Consider TDD (Test Driven Development) but always ensure code has
  unit tests and use code coverage to check this
- **DRY** (Don't Repeat Yourself) "Every piece of knowledge must have a single,
  unambiguous, authoritative representation within a system."
  ([The Pragmatic Programmer](https://media.pragprog.com/titles/tpp20/dry.pdf))
  This applies to code, data, DB schemas, documentation, processes and more
- **Architecture** Pay attention to architecture and DB schemas early in the
  design - mistakes here will derail a project
- **Naming** Good naming will aid understanding and maintainability
  - Use short names when their scope is also short, use longer names otherwise
  - Also use short names for often used components
- **Cleanliness** Always leave code in a better state than you found it
- **Be consistent**

### Languages

- Keep to a language's standard conventions and best practices
  - Unless you have more specific instructions
- Make liberal use of linters and formatters
- Ensure code adheres to the rules in `.editorconfig`
- Use [pre-commit](https://pre-commit.com/) to automatically run linters and
  formatters if it is available
  - Run `pre-commit run --all-files`
  - Or be more specific to test individual files

## Development

- All code must be tested
  - If possible, verify this using a code coverage tool
- Always obey the `.editorconfig` file if present
- All code is required to pass all linting checks.  This includes:
  - Language-specific linters
  - `pre-commit` if available
  - LSP messages from the editor or ide
  - Do not turn off any linting rules.  Ever.
    - You may suggest doing doing so, but never do it without explicit
    permission.
- All code must be formatted with language-specific tools, if available
- Unless a language specifies otherwise, use two spaces for indentation
- Lines of code should not be longer than 80 characters
  - Unless there are more specific rules fort he language or file
  - The only exception to this is for tables which cannot reasonably be
  shortened
- Do not leave any unnecessary trailing whitespace
- When documenting, focus on `why` rather than `how`
- Always use British English spelling, unless you need to be consistent with
already existing names for variables, classes, methods, APIs, systems etc.
- Run `typos` and `codespell` on all files to check for spelling mistakes
- The rules are not optional

### Documentation guidelines

- Document architecture and concepts in preference to implementation details
- Focus on `why` rather than `how`
- Documentation must also not have any lines longer than 80 characters

### Code organisation principles

- Keep individual files small and focused on a single responsibility
  - Typically no more than 300 lines of code
- Break work scripts into small, focused functions or methods
  - Typically no more than 30 lines
- Separate concerns: validation, execution, cleanup
- Use consistent naming conventions
- Group related functions together in the file
- Place helper/utility functions before main workflow functions
- Where possible define functions, subroutines and methods before they are used
- Implement error handling at appropriate levels
- Use early returns for error conditions
- Design for testability
  - Use pure functions where possible

### General development workflow

- Always check LSP output and resolve all problems after making a change
- Run language-specific linters and formatters on all changed files
- Test changes thoroughly
- Update documentation when changing code
- Consider security implications of all changes
- Consider performance implications of changes
- Review error handling paths and edge cases

### Git specific guidelines

When you make a commit it should always have an appropriate commit message.
There is a [common
standard](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
for commit messages which we extend for our purposes and which we should follow
where possible in order to keep the git repository clean and easy to follow.

- Use meaningful commit messages that explain the "why"
- The first line should be a summary and should be no longer than 50 characters
- The second line should be blank
- The message should then include more detailed explanatory text, if necessary
- Wrap it to 72 characters
- Write your commit message in the imperative: "Add wonderful feature" and not
  "Added wonderful feature" or "Adds wonderful feature" or "Wonderful feature
  added"
- This convention matches up with commit messages generated by commands like
  `git merge` and `git revert`
- Separate paragraphs with a blank line
- Bullet points are okay, too
- USe a hyphen for the bullet, followed by a single space
- Use a hanging indent

Keeping the first line to 50 characters and making it a useful summary is not
always simple but it is a good practice. If you find you want to add two or
more points to the summary then that may indicate that your commit should have
been split, or that you need to find a higher level summary and include the
separate sections in the body of the commit message.

The length limit also serves to make understanding the graph more simple which
is an important goal. Reading through the summaries of the commits in a branch
should tell a little story of how the feature was created or the bug was fixed.

Important: prefer multiple small commits over one large commit.

## Language-specific rules

- perl
  - Follow the guidelines in `perl.md`
- shell
  - Use [bash](https://www.gnu.org/software/bash/) for all new shell scripts
  - Use `shellcheck --shell=bash` for linting
  - Use `shfmt -w -i 2 -s -d` for formatting
  - Use `#!/usr/bin/env bash` as the shebang line
  - Always use `set -eEuo pipefail` and `shopt -s inherit_errexit` for error
    handling
  - Use function-based architecture with a `main()` function that orchestrates
  the workflow
  - Keep functions small and focused on single responsibilities
  - Use `local` variables in all functions to avoid global scope pollution
  - Implement comprehensive argument parsing with `--help` support
  - Include usage examples in help text
  - Validate all inputs and system requirements before execution
  - Provide clear error messages with actionable recovery suggestions
  - Implement cleanup functions for temporary resources
  - Use meaningful function and variable names
  - Add comments for complex logic, but prefer self-documenting code
  - Quote variables to prevent word splitting: `"$variable"`
  - Use `[[ ]]` or `((  ))` for conditional expressions instead of `[ ]`
  - Prefer `$(command)` over backticks for command substitution
- lua
  - Use `luacheck` for linting
  - Use `stylua` for formatting
- python
  - Use `black` for formatting
  - Use `isort` for sorting imports
- markdown
  - Use `markdownlint` for linting
  - Use `mdformat --number` for formatting
- yaml
  - Use `yamllint` for linting
  - Use `yamlfmt` for formatting
- json
  - Use `jsonlint` for linting
  - Use `fixjson` for formatting
- toml
  - Use `taplo` for formatting
- html
  - Use `tidy` for linting
- javascript
  - Use `eslint` for linting
  - Use `prettier` for formatting
- OpenAPI
  - Use `spectral` for linting
- dockerfile
  - Use `dprint` for formatting
- terraform
  - Use `terraform_fmt` for formatting
- sql
  - Use `sql_formatter` for formatting
