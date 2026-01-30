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

# --- Done ---
echo "🤖 Done! Start a new shell or run: exec zsh"
