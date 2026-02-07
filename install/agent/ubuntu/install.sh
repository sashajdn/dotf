#!/bin/bash
#
# Agent Ubuntu install script
# Sets up zsh, neovim, and tmux for SSH-accessible agent machines
#
# Usage: curl -fsSL <raw-url> | bash
#    or: ./install.sh
#

set -e

DOTF="${DOTF:-$HOME/dotf}"
NVIM_VERSION="${NVIM_VERSION:-0.11.5}"

echo "🤖 Agent Ubuntu setup starting..."

# --- Packages ---
echo "🤖 Installing packages..."
apt update
apt install -y \
    zsh \
    tmux \
    fzf \
    ripgrep \
    golang-go \
    zsh-syntax-highlighting

# --- Neovim (from GitHub releases) ---
if ! command -v nvim &> /dev/null || [[ "$(nvim --version | head -1)" != *"$NVIM_VERSION"* ]]; then
    echo "🤖 Installing neovim v${NVIM_VERSION}..."
    curl -Lo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
    rm -rf /opt/nvim
    tar -xzf /tmp/nvim.tar.gz -C /opt
    mv /opt/nvim-linux-x86_64 /opt/nvim
    ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm /tmp/nvim.tar.gz
fi

# --- eza (from GitHub releases) ---
if ! command -v eza &> /dev/null; then
    echo "🤖 Installing eza..."
    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
    tar -xzf /tmp/eza.tar.gz -C /usr/local/bin
    rm /tmp/eza.tar.gz
fi

# --- Powerlevel10k ---
if [[ ! -d /usr/share/powerlevel10k ]]; then
    echo "🤖 Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/powerlevel10k
fi

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

# --- Set default shell ---
if [[ "$SHELL" != *zsh ]]; then
    echo "🤖 Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# --- Done ---
echo "🤖 Done! Start a new shell or run: exec zsh"
