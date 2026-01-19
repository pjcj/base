---
name: local-storage
description: >-
  LLM working files and session context management. Use at the start of sessions
  to restore context, and during work to maintain state across conversations.
user-invocable: true
---

# LLM Local Storage

This skill provides guidance on using the `llm/` directory for maintaining
context and documentation across LLM sessions.

## Purpose

The `llm/` directory stores LLM-specific working files that:

- **Maintain context across sessions** - Plans, status, and documentation
- **Are not committed to git** - Working files specific to LLM sessions
- **Are branch-specific** - Each feature branch has its own directory
- **Enable seamless resumption** - Read files to understand current state

## Directory Structure

```text
llm/
└── plans/
    ├── <branch-name-1>/
    │   ├── status.md
    │   ├── implementation.md
    │   ├── test_plan.md
    │   └── ... (other context files)
    └── <branch-name-2>/
        └── ...
```

## Session Start Workflow

**IMPORTANT:** At the start of each session, follow these steps:

### 1. Check Current Branch

```bash
git branch --show-current
```

### 2. Check for Context Files

```bash
ls llm/plans/<current-branch>/
```

### 3. If Files Exist, Read Them

Read files in order of importance to restore context:

```bash
# Primary status file
cat llm/plans/<current-branch>/status.md

# Implementation details
cat llm/plans/<current-branch>/implementation.md

# Test planning
cat llm/plans/<current-branch>/test_plan.md

# Any other context files
cat llm/plans/<current-branch>/*.md
```

### 4. Use Context to Understand

- Current state and progress
- What has been completed
- What is next
- Any decisions or blockers
- Test coverage status

## Standard File Types

### status.md

Primary status tracking file containing:

- **Phase tracking** - Current phase of work
- **Completed tasks** - What has been done
- **Next steps** - Immediate actions needed
- **Blockers** - Any impediments
- **Metrics** - Coverage percentages, test counts, etc.

Example structure:

```markdown
# Status: GH-1234 Feature Name

## Current Phase
Phase 2: Implementation

## Completed
- [x] Design review
- [x] Database schema
- [x] Core module implementation

## In Progress
- [ ] API endpoints
- [ ] Unit tests

## Next Steps
1. Complete API endpoint for user creation
2. Add validation tests

## Blockers
None currently

## Metrics
- Test coverage: 85%
- Tests passing: 42/42
```

### implementation.md

Technical design and implementation details:

- Architecture decisions
- Code structure
- Key algorithms
- Integration points
- Configuration requirements

### test_plan.md

Test specifications and coverage:

- Test case descriptions
- Coverage targets
- Test file locations
- Edge cases to handle

### next_step.md

Immediate next action when resuming work. Useful for complex tasks where you
want to capture exactly what to do next.

## Maintaining Context Files

### During Work

- Update `status.md` after completing tasks
- Document decisions in `implementation.md`
- Track test progress in `test_plan.md`
- Create additional files as needed for complex work

### Before Ending Session

- Ensure `status.md` reflects current state
- Document any blockers or open questions
- Note what should be done next
- Commit actual code changes (not `llm/` files)

### Creating New Context

When starting work on a new branch:

```bash
# Create the directory
mkdir -p llm/plans/<branch-name>

# Create initial status file
cat > llm/plans/<branch-name>/status.md << 'EOF'
# Status: <Ticket> <Description>

## Current Phase
Phase 1: Planning

## Completed
- [ ] Initial analysis

## Next Steps
1. ...

## Blockers
None
EOF
```

## Best Practices

### Do

- Read context files at the start of every session
- Update status.md frequently during work
- Keep files focused and concise
- Use consistent formatting across files
- Document decisions and rationale
- Note blockers immediately when encountered

### Don't

- Commit `llm/` files to git (they're in `.gitignore`)
- Let status files become stale
- Duplicate information already in code comments
- Store sensitive data in context files
- Forget to update next steps before ending

## Integration with Development Workflow

### Starting a New Feature

1. Create branch: `git checkout -b GH-1234-feature-name`
2. Create context directory: `mkdir -p llm/plans/GH-1234-feature-name`
3. Create initial `status.md` with plan
4. Begin implementation

### Resuming Work

1. Check branch: `git branch --show-current`
2. Read context: `cat llm/plans/<branch>/status.md`
3. Review implementation notes if needed
4. Continue from documented next steps

### Completing Work

1. Update `status.md` to mark completion
2. Ensure all tests pass
3. Commit code changes
4. Context files can be deleted or kept for reference

## Example: Complex Feature

For a complex feature like `GH-1484-hybrid-type`, context files might include:

```text
llm/plans/GH-1484-hybrid-type/
├── status.md                      # Phase tracking, progress, metrics
├── implementation.md              # Technical design, architecture
├── test_plan.md                   # Test specifications, coverage
├── comprehensive_coverage_plan.md # Detailed coverage strategy
└── next_step.md                   # Immediate next action
```

This level of documentation helps maintain continuity across multiple sessions
on complex, long-running tasks.

## Quick Reference

| Action              | Command                                     |
| ------------------- | ------------------------------------------- |
| Check branch        | `git branch --show-current`                 |
| List context files  | `ls llm/plans/<branch>/`                    |
| Read status         | `cat llm/plans/<branch>/status.md`          |
| Create context dir  | `mkdir -p llm/plans/<branch>`               |
| Check if dir exists | `test -d llm/plans/<branch> && echo exists` |
