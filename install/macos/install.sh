#!/bin/bash

function check_or_install_brew() {
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

### Alacritty
brew install alacritty

### Bat
brew install bat

### Cava

### Exa
brew install exa

### FZF
brew install fzf
brew install ripgrep
$(brew --prefix)/opt/fzf/install # keybinding

### Git
brew install git

### Glow
brew install glow

### Go
brew install go
brew install golangci-lint
go install github.com/go-delve/delve/cmd/dlv@latest

### GoTop
brew install gotop

### Rust.
brew install rust-analyzer

### LF
brew install lf
### Pandoc
brew install pandoc

### Docker
brew cask install docker

### Neofetch
brew install neofetch

### Node
# brew install node

### Nvim
brew install neovim
brew install tree-sitter

### Vim
brew install vim

### Tmux
brew install tmux
brew install tmuxp

### Lua
brew install lua-language-server

### Yarn
# brew install yarn

### Zsh
brew install zsh
brew install zsh-syntax-highlighting
