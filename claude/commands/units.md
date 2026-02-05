# Units - Git Worktree Management

Manage git worktrees as units of work for parallel agent workflows.

## Instructions

When invoked, determine the subcommand and execute accordingly.

### Available Commands

| Command | Description |
|---------|-------------|
| `/units` or `/units list` | List all worktrees and their occupancy |
| `/units new <ticket>` | Create new worktree + branch for ticket |
| `/units attach <ticket>` | Attach to existing worktree |
| `/units complete` | Cleanup current worktree after merge |
| `/units sync` | Rebase current branch on latest base |

## Command Details

### `/units` or `/units list`

List all worktrees in the current repo's agents directory with occupancy status.

```bash
unit-list
```

Shows: ticket name, branch, and whether another tmux pane is currently in that worktree.

### `/units new <ticket>`

Create a new worktree for a ticket/unit of work.

```bash
unit-new <ticket-name> [branch-name]
```

This will:
1. Create `$DOTF_AGENTS_WORKTREE_DIR/<ticket>/` directory (defaults to `.agents/`)
2. Create and checkout a new branch (defaults to ticket name)
3. Base the branch on origin/main or origin/master
4. Rename the tmux pane to include the ticket name

After running, `cd` into the worktree path shown.

### `/units attach <ticket>`

Attach to an existing worktree.

```bash
unit-attach <ticket-name>
```

This will:
1. Verify the worktree exists
2. Warn if another pane is already in that worktree
3. Rename the tmux pane to include the ticket name

After running, `cd` into the worktree path shown.

### `/units complete`

Clean up a worktree after work is complete (PR merged).

```bash
unit-complete [ticket-name]
```

If run from within a worktree, uses the current worktree. Otherwise requires ticket name.

This will:
1. Move out of the worktree directory
2. Remove the worktree
3. Optionally delete the branch
4. Reset the tmux pane name

### `/units sync`

Sync current worktree with the latest base branch.

```bash
unit-sync
```

This will:
1. Fetch latest from origin
2. Stash uncommitted changes (if any, with confirmation)
3. Rebase onto origin/main or origin/master
4. Restore stashed changes

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `DOTF_AGENTS_WORKTREE_DIR` | `.agents` | Directory name for worktrees within repo |

## Workflow Example

```
# 1. List existing worktrees
/units list

# 2. Create worktree for new ticket
/units new exp-3803-fixup-auth

# 3. cd into the worktree
cd .agents/exp-3803-fixup-auth

# 4. Work on the ticket...

# 5. Keep in sync with main
/units sync

# 6. After PR is merged, cleanup
/units complete
```

## Pane Naming Convention

Format: `{repo}:{agent-N}:{ticket}` (all lowercase, only `:` and `-`)

Examples:
- Before attach: `api-service:agent-1`
- After attach: `api-service:agent-1:exp-3803-fixup-auth`

This makes it easy to see which agent is working on which ticket via `<prefix> + f` (pane finder).

## Prerequisites

- Must be in a git repository
- Must be running inside tmux (for pane renaming)
- The `unit-*` scripts must be in PATH (`~/dotf/bin/local/bin/`)
