#!/bin/bash
#
# Agent Ubuntu install script
# Sets up zsh, neovim, and tmux for SSH-accessible agent machines
#
# Usage: curl -fsSL <raw-url> | bash
#    or: ./install.sh
#

set -e

DOTF="${DOTF:-$HOME/repos/dotf}"

echo "🤖 Agent Ubuntu setup starting..."

# --- Packages ---
echo "🤖 Installing packages..."
apt update
apt install -y \
    zsh \
    neovim \
    tmux \
    fzf \
    ripgrep \
    golang-go \
    zsh-syntax-highlighting

# eza (not in apt, install from GitHub)
if ! command -v eza &> /dev/null; then
    echo "🤖 Installing eza..."
    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
    tar -xzf /tmp/eza.tar.gz -C /usr/local/bin
    rm /tmp/eza.tar.gz
fi

# powerlevel10k (clone to standard location)
if [[ ! -d /usr/share/powerlevel10k ]]; then
    echo "🤖 Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/powerlevel10k
fi

# --- Directories ---
echo "🤖 Creating directories..."
mkdir -p ~/.config ~/.cache/zsh

# --- Symlinks ---
echo "🤖 Creating symlinks..."

# Dotf convenience symlink (zshrc expects ~/dotf)
ln -sf "$DOTF" ~/dotf

# Zsh
ln -sf "$DOTF/zsh/zshrc" ~/.zshrc

# Neovim
ln -sf "$DOTF/nvim" ~/.config/nvim

# Tmux
ln -sf "$DOTF/tmux" ~/.config/tmux

# --- Set default shell ---
if [[ "$SHELL" != *zsh ]]; then
    echo "🤖 Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# --- Done ---
echo "🤖 Done! Start a new shell or run: exec zsh"
