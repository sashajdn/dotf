#!/bin/bash
#
# Agent macOS install script
# Sets up zsh, neovim, and tmux for SSH-accessible agent machines
#
# Usage: curl -fsSL <raw-url> | bash
#    or: ./install.sh
#

set -e

DOTF="${DOTF:-$HOME/dotf}"

echo "🤖 Agent macOS setup starting..."

# --- Homebrew ---
if ! command -v brew &> /dev/null; then
    echo "🤖 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Packages ---
echo "🤖 Installing packages..."
brew install \
    neovim \
    tmux \
    fzf \
    eza \
    ripgrep \
    zsh-syntax-highlighting \
    powerlevel10k

# --- Directories ---
echo "🤖 Creating directories..."
mkdir -p ~/.config ~/.cache/zsh

# --- Symlinks ---
echo "🤖 Creating symlinks..."

# Zsh
ln -sf "$DOTF/zsh/zshrc" ~/.zshrc

# Neovim
ln -sf "$DOTF/nvim" ~/.config/nvim

# Tmux
ln -sf "$DOTF/tmux" ~/.config/tmux

# --- Coding Agents ---
echo "🤖 Installing coding agents..."

# Claude Code
if ! command -v claude &> /dev/null; then
    echo "🤖 Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

# Amp (Sourcegraph)
if ! command -v amp &> /dev/null; then
    echo "🤖 Installing Amp..."
    npm install -g @sourcegraph/amp
fi

# OpenAI Codex
if ! command -v codex &> /dev/null; then
    echo "🤖 Installing OpenAI Codex..."
    npm install -g @openai/codex
fi

# --- Done ---
echo "🤖 Done! Start a new shell or run: exec zsh"
