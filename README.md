# @sashajdn dotfiles

Personal dotfiles with multi-user support (human + agent profiles).

## Structure

```
dotf/
├── bin/local/bin/     # Custom scripts (unit-*, tmux-*)
├── claude/
│   ├── agents/        # Claude Code agents (symlinked to ~/.claude/agents)
│   └── commands/      # Claude Code skills (symlinked to ~/.claude/commands)
├── config/            # App configs (ghostty, etc.)
├── install/
│   ├── human/         # Human install scripts
│   └── agent/         # Agent install scripts
├── nvim/              # Neovim configuration
├── tmux/              # Tmux configuration
└── zsh/               # Zsh configuration
```

## Install

```bash
# Clone
git clone git@github.com:sashajdn/dotf.git ~/dotf

# Human setup (interactive use)
make install-macos

# Agent setup (CI/automated environments)
make install-macos-agent
```

---

## Multi-Agent Workflow

Run multiple Claude Code agents in parallel on the same repo using git worktrees.

### Architecture

```mermaid
graph TB
    subgraph "tmux session: api-service"
        subgraph "window: api-service-code"
            H[Human Terminal]
        end
        subgraph "window: api-service-agents"
            A1[agent-1<br/>exp-3803-auth]
            A2[agent-2<br/>bug-1234-fix]
            A3[agent-3<br/>idle]
            A4[agent-4<br/>idle]
        end
    end

    subgraph "repo: ~/repos/api-service"
        MAIN[main repo]
        subgraph ".agents/"
            W1[exp-3803-auth/]
            W2[bug-1234-fix/]
        end
    end

    A1 --> W1
    A2 --> W2
    H --> MAIN
```

### Workflow

```mermaid
sequenceDiagram
    participant H as Human
    participant A as Agent
    participant G as Git
    participant T as tmux

    H->>T: ctrl-f (tmux-sessionizer)
    T->>T: Create session + agent panes

    H->>A: Start claude --agent units-agent
    A->>A: /units new exp-3803-auth
    A->>G: git worktree add .agents/exp-3803-auth
    A->>T: Rename pane → repo:agent-1:exp-3803-auth

    loop Development
        A->>A: Work on ticket
        A->>A: /units sync (rebase on main)
    end

    A->>G: Create PR
    H->>G: Merge PR
    A->>A: /units complete
    A->>G: git worktree remove
    A->>T: Rename pane → repo:agent-1
```

### Quick Reference

| Action | Command |
|--------|---------|
| Open repo session | `ctrl-f` → select repo |
| Start agent | `claude --agent units-agent` |
| Create worktree | `/units new <ticket>` |
| List worktrees | `/units list` |
| Attach to worktree | `/units attach <ticket>` |
| Sync with main | `/units sync` |
| Cleanup worktree | `/units complete` |
| Find pane (fzf) | `<C-a> + f` |
| Split into N agents | `<C-a> + a` → enter N |

### Pane Naming

Format: `{repo}:{agent-N}:{ticket}` (lowercase, only `:` and `-`)

```
api-service:agent-1                    # idle
api-service:agent-1:exp-3803-auth      # working on ticket
api-service:agent-2:bug-1234-fix       # working on ticket
```

### Directory Layout

```
~/repos/api-service/
├── .git/
├── src/
└── .agents/                           # DOTF_AGENTS_WORKTREE_DIR
    ├── exp-3803-auth/                 # worktree for ticket
    │   ├── .git                       # file pointing to main .git
    │   └── src/
    └── bug-1234-fix/                  # another worktree
```

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `MAX_AGENTS` | `4` | Max agent panes per repo |
| `DOTF_AGENTS_WORKTREE_DIR` | `.agents` | Worktree directory name |

Add to global gitignore:
```bash
echo ".agents" >> ~/.gitignore
git config --global core.excludesFile ~/.gitignore
```

### tmux Keybindings

| Key | Action |
|-----|--------|
| `<C-a> + f` | fzf pane finder (across all sessions) |
| `<C-a> + a` | Split window into N agent panes |
| `<C-a> + h/j/k/l` | Navigate panes |
| `<C-a> + o` | Switch to last session |

### Pane Colors (Oxocarbon)

Each agent pane has a distinct border color:
- Agent 1: Pink (`#ff7eb6`)
- Agent 2: Cyan (`#3ddbd9`)
- Agent 3: Green (`#42be65`)
- Agent 4: Purple (`#be95ff`)

---

## Visuals

![Golang](./assets/1.png)
![Telescope](./assets/2.png)
![Python](./assets/3.png)
