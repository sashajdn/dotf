---
name: obsidian
description: Use when the user invokes $obsidian or asks to work in an Obsidian vault or scratchpad. Use the local Obsidian CLI only for live app state; edit Markdown directly by default.
---

# Obsidian CLI

Use `obsidian` only for live Obsidian state: inspect, search, navigate, open, or focus.

1. Check `command -v obsidian`. If absent, report that the CLI must be installed or enabled.
2. Infer the vault from context. If unclear and `wiki` exists, use `vault=wiki`; otherwise run `obsidian vaults verbose`.
3. Run `obsidian help <command>` instead of guessing arguments. Prefer exact vault-relative `path=` values; use `file=` only for name resolution.
4. Default to read-only commands. Make changes or operate the UI only when requested. Never use `delete ... permanent` without explicit confirmation.
5. Report the result concisely.
6. For a request that names a scratchpad or targets `scratchpads/`, first read and follow [the scratchpad contract](/Users/alexjperkins/wiki/scratchpads/AGENTS.md). Treat it as volatile: replace its current working model rather than append history. Persist material only when the user names a separate destination. On first use in a fresh context, open and focus the scratchpad once; thereafter do not invoke the CLI to reread, open, focus, or verify an ordinary edit.
