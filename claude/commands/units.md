# Units - Git Worktree Management

Manage git worktrees as units of work for parallel agent workflows.

## Instructions

When invoked, run the appropriate `unit-*` command and report the result. The user will handle directory changes themselves.

### Available Commands

| Command | Description |
|---------|-------------|
| `/units` or `/units list` | List all worktrees and their occupancy |
| `/units new <ticket>` | Create new worktree + branch |
| `/units attach <ticket>` | Mark attachment to existing worktree |
| `/units complete <ticket>` | Cleanup worktree after merge |
| `/units sync` | Rebase current branch on latest base |

## Command Details

### `/units` or `/units list`

```bash
unit-list
```

### `/units new <ticket>`

```bash
unit-new <ticket-name>
```

After running, output the path clearly so the user can cd into it:

```
Worktree created. Run:
cd /path/to/.agents/<ticket>
```

### `/units attach <ticket>`

```bash
unit-attach <ticket-name>
```

After running, output the path for the user to cd into.

### `/units complete <ticket>`

```bash
unit-complete -y <ticket-name>
```

### `/units sync`

Run from within the worktree:

```bash
unit-sync
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTF_AGENTS_WORKTREE_DIR` | `.agents` | Worktree directory name |

## Pane Naming

Format: `{repo}:{agent-N}:{ticket}` (lowercase, `:` and `-` only)
