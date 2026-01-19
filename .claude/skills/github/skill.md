---
name: github
description: >-
  GitHub CLI (gh) reference. Use when working with GitHub pull requests,
  issues, Actions workflows, releases, repositories, or the GitHub API.
  Covers gh commands, common workflows, and troubleshooting.
user-invocable: true
---

# GitHub CLI (gh) Reference

This skill provides guidance on using the `gh` CLI tool to interact with
GitHub from the command line.

## What is gh?

`gh` is GitHub's official command-line tool that brings GitHub functionality
to your terminal. It allows you to work with pull requests, issues, Actions
workflows, releases, and more without leaving your development environment.

## When to Use gh

Use `gh` for:

- **Pull requests** - Create, view, review, merge, and manage PRs
- **Issues** - Create, list, comment, and manage GitHub issues
- **Actions** - View workflow runs, trigger workflows, view logs
- **Releases** - Create releases, upload assets, manage tags
- **Repository operations** - Clone, fork, view project info
- **API access** - Make authenticated requests to the GitHub APIs
- **Gists** - Create, view, and manage gists
- **Notifications** - View and manage GitHub notifications

## Authentication

gh uses GitHub authentication via browser or token. Check authentication status:

```bash
gh auth status
```

If not authenticated, run:

```bash
gh auth login
```

## Core Commands Reference

### Pull Requests (`gh pr`)

| Command                           | Purpose                             |
| --------------------------------- | ----------------------------------- |
| `gh pr create`                    | Create a new pull request           |
| `gh pr list`                      | List pull requests                  |
| `gh pr view <number>`             | View PR details                     |
| `gh pr view --web`                | Open current branch's PR in browser |
| `gh pr checkout <number>`         | Check out a PR locally              |
| `gh pr merge <number>`            | Merge a PR                          |
| `gh pr review <number>`           | Add a review to a PR                |
| `gh pr diff <number>`             | View PR diff                        |
| `gh pr comment <number> -b "..."` | Add a comment to a PR               |
| `gh pr edit <number>`             | Edit PR title/body/settings         |
| `gh pr ready <number>`            | Mark draft PR as ready for review   |
| `gh pr close <number>`            | Close a PR                          |
| `gh pr reopen <number>`           | Reopen a closed PR                  |
| `gh pr checks <number>`           | View CI status checks               |

**Common PR creation:**

```bash
# Create PR with title and body
gh pr create \
  --title "Add feature X" \
  --base main \
  --body "## Summary

Description here"

# Create PR and fill from commits
gh pr create --fill

# Create draft PR
gh pr create --draft --fill

# Create PR with reviewers and labels
gh pr create --fill --reviewer user1,user2 --label bug,urgent
```

**PR review workflow:**

```bash
# Approve a PR
gh pr review 123 --approve

# Request changes
gh pr review 123 --request-changes --body "Please fix X"

# Leave a comment review
gh pr review 123 --comment --body "Looks good overall"
```

### Issues (`gh issue`)

| Command                              | Purpose                          |
| ------------------------------------ | -------------------------------- |
| `gh issue list`                      | List project issues              |
| `gh issue create`                    | Create a new issue               |
| `gh issue view <number>`             | View issue details               |
| `gh issue close <number>`            | Close an issue                   |
| `gh issue reopen <number>`           | Reopen an issue                  |
| `gh issue comment <number> -b "..."` | Comment on an issue              |
| `gh issue edit <number>`             | Edit issue details               |
| `gh issue status`                    | Show status of relevant issues   |
| `gh issue develop <number>`          | Create a branch for an issue     |

**Common issue workflows:**

```bash
# List open issues assigned to you
gh issue list --assignee @me

# Create issue with labels
gh issue create --title "Bug: X" --body "Description" --label bug

# Create branch for issue and link it
gh issue develop 123 --checkout

# Close issue with comment
gh issue close 123 --comment "Fixed in #456"
```

### GitHub Actions (`gh run` and `gh workflow`)

| Command                              | Purpose                        |
| ------------------------------------ | ------------------------------ |
| `gh run list`                        | List recent workflow runs      |
| `gh run view <run-id>`               | View workflow run details      |
| `gh run watch <run-id>`              | Watch a run until completion   |
| `gh run rerun <run-id>`              | Re-run a workflow run          |
| `gh run cancel <run-id>`             | Cancel a workflow run          |
| `gh run download <run-id>`           | Download run artifacts         |
| `gh run view <run-id> --log`         | View run logs                  |
| `gh workflow list`                   | List workflows                 |
| `gh workflow view <workflow>`        | View workflow details          |
| `gh workflow run <workflow>`         | Trigger a workflow             |
| `gh workflow disable <workflow>`     | Disable a workflow             |
| `gh workflow enable <workflow>`      | Enable a workflow              |

**Common Actions workflows:**

```bash
# View status of latest runs
gh run list --limit 5

# Watch current branch's workflow
gh run list --branch $(git branch --show-current) --limit 1
gh run watch

# View failed job logs
gh run view 123456 --log-failed

# Re-run failed jobs only
gh run rerun 123456 --failed

# Trigger workflow with inputs
gh workflow run ci.yml --ref main -f environment=staging

# Download artifacts from a run
gh run download 123456 -n artifact-name
```

### Releases (`gh release`)

| Command                                | Purpose                    |
| -------------------------------------- | -------------------------- |
| `gh release list`                      | List releases              |
| `gh release view <tag>`                | View release details       |
| `gh release create <tag>`              | Create a release           |
| `gh release delete <tag>`              | Delete a release           |
| `gh release download <tag>`            | Download release assets    |
| `gh release upload <tag> <files...>`   | Upload assets to release   |
| `gh release edit <tag>`                | Edit release details       |

**Common release workflows:**

```bash
# Create release from tag
gh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes here"

# Create release with auto-generated notes
gh release create v1.0.0 --generate-notes

# Create draft release
gh release create v1.0.0 --draft --generate-notes

# Upload assets to existing release
gh release upload v1.0.0 dist/*.tar.gz

# Create release with assets
gh release create v1.0.0 dist/*.tar.gz --title "v1.0.0" --notes "Notes"
```

### Repository (`gh repo`)

| Command                     | Purpose                    |
| --------------------------- | -------------------------- |
| `gh repo view`              | View current repo info     |
| `gh repo view --web`        | Open repo in browser       |
| `gh repo clone <repo>`      | Clone a repository         |
| `gh repo fork <repo>`       | Fork a repository          |
| `gh repo create`            | Create a new repository    |
| `gh repo list`              | List your repositories     |
| `gh repo rename <new-name>` | Rename a repository        |
| `gh repo sync`              | Sync a fork with upstream  |
| `gh repo set-default`       | Set default repository     |

### API Access (`gh api`)

Make authenticated requests to the GitHub API:

```bash
# Get repository info
gh api repos/{owner}/{repo}

# Get authenticated user
gh api user

# List repository issues
gh api repos/{owner}/{repo}/issues

# Create an issue via API
gh api repos/{owner}/{repo}/issues -f title="Bug" -f body="Description"

# Paginate through results
gh api repos/{owner}/{repo}/issues --paginate

# GraphQL query
gh api graphql -f query='
  query {
    viewer {
      login
      repositories(first: 10) {
        nodes {
          name
        }
      }
    }
  }
'

# Use jq for processing JSON
gh api repos/{owner}/{repo}/pulls --jq '.[].title'
```

**Useful placeholders:**

- `{owner}` - Repository owner (auto-filled from current repo)
- `{repo}` - Repository name (auto-filled from current repo)
- `{branch}` - Current branch name

### Search (`gh search`)

| Command                          | Purpose                |
| -------------------------------- | ---------------------- |
| `gh search repos <query>`        | Search repositories    |
| `gh search issues <query>`       | Search issues          |
| `gh search prs <query>`          | Search pull requests   |
| `gh search commits <query>`      | Search commits         |
| `gh search code <query>`         | Search code            |

**Common search examples:**

```bash
# Search issues in current repo
gh search issues --repo {owner}/{repo} "bug"

# Search open PRs authored by you
gh search prs --author @me --state open

# Search code in a specific language
gh search code "function authenticate" --language javascript

# Search repos with specific topic
gh search repos --topic rust --language rust --stars ">1000"
```

### Gists (`gh gist`)

| Command                        | Purpose               |
| ------------------------------ | --------------------- |
| `gh gist list`                 | List your gists       |
| `gh gist view <id>`            | View a gist           |
| `gh gist create <files...>`    | Create a gist         |
| `gh gist edit <id>`            | Edit a gist           |
| `gh gist delete <id>`          | Delete a gist         |
| `gh gist clone <id>`           | Clone a gist          |

```bash
# Create public gist from file
gh gist create script.sh --public

# Create gist from stdin
echo "content" | gh gist create -f filename.txt

# Create gist with description
gh gist create file.py --desc "Python helper script"
```

## Common Workflows

### Check CI Status and View Logs

```bash
# Quick status of PR checks
gh pr checks

# View workflow runs for current branch
gh run list --branch $(git branch --show-current)

# Watch the latest run
gh run watch

# If failed, view the logs
gh run view --log-failed
```

### Review a Pull Request

```bash
# View PR details
gh pr view 123

# View the diff
gh pr diff 123

# Check out locally to test
gh pr checkout 123

# Run tests, then approve
gh pr review 123 --approve --body "LGTM, tested locally"
```

### Create PR with Full Workflow

```bash
# Ensure branch is pushed
git push -u origin HEAD

# Create PR with auto-fill
gh pr create --fill

# Or create with all details
gh pr create \
  --title "feat: Add X feature" \
  --body "## Summary
- Added X
- Fixed Y

## Test Plan
- Ran unit tests
- Manual testing" \
  --reviewer team-lead \
  --label enhancement
```

### Work with Forks

```bash
# Fork and clone a repo
gh repo fork owner/repo --clone

# Sync fork with upstream
gh repo sync

# Create PR to upstream
gh pr create --repo owner/repo
```

### Manage Notifications

```bash
# View unread notifications
gh api notifications --jq '.[] | "\(.subject.type): \(.subject.title)"'

# Mark all as read
gh api notifications -X PUT -f read=true
```

## Useful Flags

### Global flags (work with most commands)

- `-R, --repo OWNER/REPO` - Target a different repository
- `--json <fields>` - Output specific fields as JSON
- `--jq <query>` - Filter JSON output with jq syntax
- `--template <template>` - Format output with Go template

### PR/Issue flags

- `--web` - Open in browser
- `--assignee @me` - Filter by assignment to self
- `--author @me` - Filter by authored by self
- `--state open|closed|merged|all` - Filter by state
- `--label <label>` - Filter by label
- `--limit <n>` - Limit number of results

### Output formatting

```bash
# JSON output with specific fields
gh pr list --json number,title,author

# JSON with jq filtering
gh pr list --json number,title --jq '.[].title'

# Go template formatting
gh pr list --json number,title \
  --template '{{range .}}#{{.number}} {{.title}}{{"\n"}}{{end}}'
```

## Troubleshooting

### "gh: command not found"

Install gh via package manager:

```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Other: https://cli.github.com/
```

### Authentication errors

```bash
# Check current auth status
gh auth status

# Re-authenticate
gh auth login

# Refresh authentication
gh auth refresh
```

### "repository not found" or permission errors

Ensure you're in a git repository with a GitHub remote, or specify the repo:

```bash
gh pr list -R owner/repo
```

### Set default repository

If working outside a git repo or with multiple remotes:

```bash
gh repo set-default owner/repo
```

### Rate limiting

Check your rate limit status:

```bash
gh api rate_limit
```

For bulk operations, use pagination:

```bash
gh api repos/{owner}/{repo}/issues --paginate
```

## Extensions

gh supports extensions for additional functionality:

```bash
# List installed extensions
gh extension list

# Install an extension
gh extension install owner/gh-extension

# Popular extensions:
# gh-dash - Dashboard for PRs and issues
# gh-copilot - GitHub Copilot in CLI
# gh-markdown-preview - Preview markdown
```

## Getting Help

```bash
# General help
gh --help

# Command-specific help
gh pr --help
gh pr create --help

# View manual page
gh help pr

# Check version
gh --version
```

## Reference Links

- [GitHub CLI documentation](https://cli.github.com/manual/)
- [GitHub REST API](https://docs.github.com/en/rest)
- [GitHub GraphQL API](https://docs.github.com/en/graphql)
- [gh extensions](https://github.com/topics/gh-extension)
