# CLAUDE.md

Guidelines for working with this dotfiles repository.

## Philosophy

**It should just work.** No debugging, no fiddling. Clone, run install, done.

**Terminal-first.** Terminal + tmux + neovim is the IDE. Everything else is secondary.

**Blazingly fast.** Neovim must be instant for all languages. No lag, no delays, no excuses.

## Principles

- **Simplistic** - Less is more. Remove before adding.
- **Modular** - Each component is self-contained and replaceable.
- **Safe** - Idempotent scripts. Re-run without fear.
- **Explicit** - No magic. Readable over clever.

## Architecture

**Multi-user profiles:**
- `install/human/` - Interactive use with full tooling
- `install/agent/` - CI/automated environments, minimal footprint

**LSP strategy:** Mason manages all language servers, not brew. Keeps neovim self-contained.

**Symlinks:** Relative paths for portability across machines.

## Languages

Neovim must provide first-class support for:
- Rust (primary)
- Go
- Python
- TypeScript
- C++
- Assembly
- Lua
- YAML
- JSON
- SQL

For all languages with LSP support: go-to-definition, find references, rename, hover docs, and diagnostics must work instantly out of the box. No setup, no configuration per project.

## Bash/Zsh Standards

- Always `set -euo pipefail`
- Idempotent operations (check before create)
- `readonly` for constants
- Functions over inline scripts
- Logging with clear prefixes
