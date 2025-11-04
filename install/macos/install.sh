#!/bin/bashmins check_or_install_brew() {
	if ! command -v brew &> /dev/null
	then
		echo "Installing brew..."
		/bin/bash -c \
			"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi

}

### Brew
check_or_install_brew
brew update

### Git
echo "🎋 Installing git..."
brew install git
echo "✅ Installed git"

### Exa
brew install eza

### FZF
brew install fzf
brew install ripgrep
$(brew --prefix)/opt/fzf/install # keybinding

### Go
brew install go
brew install golangci-lint

### GoTop
brew install gotop

### Rust.
brew install rust-analyzer

### Neofetch
brew install neofetch

### Nvim
brew install neovim
brew install tree-sitter

### Tmux
brew install tmux
brew install tmuxp

### Lua
brew install lua-language-server

### Zsh
brew install zsh
brew install zsh-syntax-highlighting

### C++
brew install llvm
export PATH="$PATH:$(brew --prefix llvm)/bin"

### LLMs
brew install codex
