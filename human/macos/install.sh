#!/usr/bin/env bash
#
# Human macOS install script
# Provisions a fresh macOS machine with dotfiles, packages, and repos
#
# Usage: make install-macos
#

set -euo pipefail

readonly DOTF="${DOTF:-$HOME/dotf}"
readonly REPO_DIR="${REPO_DIR:-$HOME/repos}"

# --- Logging ---
log_info()  { printf '➡️  %s\n' "$*"; }
log_ok()    { printf '✅ %s\n' "$*"; }
log_warn()  { printf '⚠️  %s\n' "$*" >&2; }

# --- Homebrew ---
install_homebrew() {
    if command -v brew &>/dev/null; then
        log_ok "Homebrew already installed"
        return
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    log_ok "Homebrew installed"
}

# --- Packages ---
install_packages() {
    log_info "Installing packages..."

    local packages=(
        # Core
        git
        neovim
        tmux
        fzf
        eza
        ripgrep

        # Zsh
        zsh
        zsh-syntax-highlighting
        powerlevel10k

        # Languages (LSPs handled by Mason)
        go
        golangci-lint

        # Tools
        tree-sitter
        gh
    )

    brew update
    brew install "${packages[@]}"

    log_ok "Packages installed"
}

# --- Directories ---
create_directories() {
    log_info "Creating directories..."

    mkdir -p ~/.config
    mkdir -p ~/.cache/zsh
    mkdir -p ~/.claude
    mkdir -p "$REPO_DIR"

    log_ok "Directories created"
}

# --- Symlinks ---
create_symlinks() {
    log_info "Creating symlinks..."

    ln -sf "$DOTF/zsh/zshrc" ~/.zshrc
    ln -sf "$DOTF/nvim" ~/.config/nvim
    ln -sf "$DOTF/tmux" ~/.config/tmux
    ln -sf "$DOTF/claude/commands" ~/.claude/commands

    log_ok "Symlinks created"
}

# --- Repos ---
clone_repos() {
    log_info "Cloning repos..."

    local repos=(
        "git@github.com:sashajdn/gogorithms.git"
        "git@github.com:sashajdn/rustgorithms.git"
        "git@github.com:sashajdn/roml.git"
        "git@github.com:sashajdn/pygos.git"
        "git@github.com:sashajdn/orderbook.git"
        "git@github.com:sashajdn/intervention.git"
        "git@github.com:sashajdn/sushidog.git"
    )

    for repo in "${repos[@]}"; do
        local name
        name=$(basename "$repo" .git)
        local dest="$REPO_DIR/$name"

        if [[ -d "$dest" ]]; then
            log_warn "$name already exists, skipping"
            continue
        fi

        git clone "$repo" "$dest" || log_warn "Failed to clone $name"
    done

    log_ok "Repos cloned"
}

# --- Sanki ---
install_sanki() {
    if command -v sanki &>/dev/null; then
        log_ok "Sanki already installed"
        return
    fi

    log_info "Installing Sanki..."

    local sanki_dir="$REPO_DIR/sanki"
    if [[ ! -d "$sanki_dir" ]]; then
        git clone https://github.com/sashajdn/sanki.git "$sanki_dir"
    fi

    (cd "$sanki_dir" && make install)
    log_ok "Sanki installed"
}

# --- Main ---
main() {
    log_info "Human macOS setup starting..."

    install_homebrew
    install_packages
    create_directories
    create_symlinks
    clone_repos
    install_sanki

    log_ok "Done! Start a new shell or run: exec zsh"
}

main "$@"
