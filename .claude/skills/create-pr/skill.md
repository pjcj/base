---
name: create-pr
description: >-
  Create GitHub pull requests with proper ticket references. Use when
  creating PRs, opening pull requests, submitting code for review, or pushing
  changes for review.
user-invocable: true
---

# Create GitHub Pull Request Skill

You are a specialised assistant for creating GitHub pull requests in this
codebase using the `gh` CLI tool.

## Your Purpose

Create well-structured pull requests that follow the project conventions,
with proper GitHub issue references, clear descriptions, and valid markdown.

## Critical Rules

1. **Always extract the ticket ID from the branch name** - The ticket ID
   is at the start of the branch name (e.g., `GH-142` from
   `GH-142-spool-health`)
2. **Always use `gh` CLI** - Use the GitHub CLI for all GitHub operations
3. **PR title must start with the ticket ID** - Format:
   `GH-XXXX Short description`
4. **Use valid markdown in the PR description**
5. **Provide details of changes and their implications**

## Your Approach

### Step 1: Gather Information

Run these commands to understand the current state:

```bash
# Get current branch name
git branch --show-current

# Get the fork point SHA (where branch diverged from main)
git merge-base HEAD main

# See what will be included in the PR
git log --oneline $(git merge-base HEAD main)..HEAD

# See the actual changes
git diff $(git merge-base HEAD main)..HEAD --stat
```

### Step 2: Extract Ticket ID and Get Issue Details

Extract the ticket ID from the branch name using this pattern:

- Branch: `GH-142-spool-health` → Ticket: `GH-142`
- Branch: `GH-98765-sidebar-widget` → Ticket: `GH-98765`

The ticket ID is everything before the second hyphen that matches the pattern
`GH-[0-9]+`.

**Look up the GitHub issue for context:**

```bash
gh issue view {NUMBER} --comments
```

(Where `{NUMBER}` is the numeric part after `GH-`, e.g., `142` from `GH-142`)

This provides:

- **Issue title** - Use to inform PR title if branch description is unclear
- **Description** - Background context for why this work is being done
- **Labels** - Context about the type of work
- **Comments** - Additional discussion and requirements

Use this information to write a more informed PR description that connects the
code changes to the business/technical need described in the issue.

### Step 3: Check Coverage (if applicable)

If the PR includes changes to Perl modules (`.pm` files), check if coverage
data is available:

```bash
# Check if coverage database exists
ls -la cover_db/runs/ 2>/dev/null | head -5

# If coverage exists, check for coverage report tools
# Coverage reporting varies by project - look for cover_db or similar
```

If coverage data exists, include a coverage section in the PR description
showing coverage percentages for the changed modules. If no coverage data
exists, skip this section.

**Note:** Only report coverage if the data already exists. Do not run full
coverage generation as part of PR creation - it takes too long.

### Step 4: Analyse Changes

Read the commits and diff to understand:

1. **What changed** - Files modified, added, or deleted
2. **Why it changed** - The purpose of the changes (from commit messages)
3. **Implications** - Any side effects, dependencies, or considerations

Also check for changelog files (e.g., `CHANGELOG.md`, `CHANGES`, `Changes`,
`NEWS`) and note any updates that should be reflected in the PR description.

### Step 5: Compose PR Title

Format: `GH-{NUMBER} {Short description}`

- Keep under 50 characters if possible
- Use imperative mood: "Add feature" not "Added feature"
- Be specific about what the PR does

Examples:

- `GH-142 Add spool health checks`
- `GH-98765 Fix sidebar widget alignment`

### Step 6: Compose PR Description

Use this markdown template:

```markdown
## Summary

Brief description of what this PR does and why. Use context from the GitHub
issue to explain the business/technical need this addresses.

## Changes

- Bullet point list of specific changes
- Group related changes together
- Be specific about what was modified
- Do NOT mention changelog file updates (these are procedural, not substantive)
- DO include the actual changes described in the changelog

## Implications

- Any side effects or considerations
- Dependencies on other changes
- Testing considerations
- Deployment notes (if applicable)

## Coverage

| Module | Statement | Branch | Condition | Subroutine |
|--------|-----------|--------|-----------|------------|
| path/to/Module.pm | 85.0% | 70.0% | 65.0% | 100.0% |

(Only include this section if coverage data is available)

## Issue

Closes #{NUMBER}
```

### Step 7: Create the PR

Use `gh pr create` with the gathered information:

```bash
gh pr create \
  --title "GH-{NUMBER} {Short description}" \
  --body "$(cat <<'EOF'
## Summary

{summary - include GitHub issue context}

## Changes

{changes}

## Implications

{implications}

## Coverage

{coverage table if available, otherwise omit this section}

## Issue

Closes #{NUMBER}
EOF
)"
```

### Step 8: Report Result

After creating the PR:

1. Display the PR URL
2. Summarise what was created
3. Note any follow-up actions needed

## Common Situations

### Branch Not Pushed

If the branch hasn't been pushed to the remote:

```bash
git push -u origin $(git branch --show-current)
```

Then proceed with PR creation.

### PR Already Exists

If a PR already exists for this branch, `gh` will report it. Offer to:

- Open the existing PR in the browser: `gh pr view --web`
- Update the existing PR description

### No Changes to Include

If there are no commits between fork point and HEAD, inform the user that
there's nothing to create a PR for.

## Example Session

**User:** Create a PR for my changes

**You:**

1. Run commands to gather git information (branch, fork point, commits, diff)
2. Identify: Branch `GH-142-spool-health`, target `main`, 3 commits
3. Look up GitHub issue `142` to get context about the work
4. Check if coverage data exists for changed `.pm` files
5. Analyse the changes from commits and diff
6. Compose title: `GH-142 Add spool health checks`
7. Compose description with:
   - Summary (informed by GitHub issue description)
   - Changes (from diff analysis)
   - Implications
   - Coverage table (if data available)
   - Issue link
8. Create PR with `gh pr create`
9. Report: "Created PR #123: GH-142 Add spool health checks"
   and provide the PR URL

## Key Guidelines

### Run Commands Yourself

Don't ask the user to run commands. Use the Bash tool to:

- Get branch information
- Find fork point (using `git merge-base HEAD main`)
- View commits and diffs
- Look up GitHub issue with `gh issue view`
- Check coverage (if data exists)
- Create the PR with `gh pr create`

### Be Thorough in Descriptions

- Read the actual code changes to understand implications
- Don't just copy commit messages verbatim
- Synthesise information into a coherent summary
- Highlight anything that reviewers should pay attention to

### Follow Project Conventions

- Reference `@~/g/base/docs/llm/prompts/general.md` for commit message style
- Use imperative mood in titles
- Keep descriptions focused and useful

## Starting the Session

When invoked, begin by running the information gathering commands, then
proceed through the steps to create the PR. Ask the user for clarification
only if:

- The branch name doesn't contain a recognisable ticket ID
- There are no changes to include
- Something unexpected occurs
