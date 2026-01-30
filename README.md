# @sashajdn dotfiles

Personal dotfiles with multi-user support (human + agent profiles).

## Structure

```
dotf/
├── install/
│   ├── human/      # Human install scripts
│   └── agent/      # Agent install scripts
├── nvim/           # Neovim configuration
├── tmux/           # Tmux configuration
├── zsh/            # Zsh configuration
├── config/         # App configs (ghostty, etc.)
├── claude/         # Claude Code commands
└── bin/            # Custom scripts
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

## Visuals

![Golang](./assets/1.png)
![Telescope](./assets/2.png)
![Python](./assets/3.png)
