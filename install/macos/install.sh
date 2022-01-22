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

### Git
brew install git

### Glow
brew install glow

### Go
# brew install go

### GoTop
brew install gotop

### LF
brew install lf
### Pandoc
brew install pandoc

### Python
brew install python

### Docker
brew cask install docker

### Neofetch
brew install neofetch

### Node
# brew install node

### Nvim
brew install neovim

### Vim
brew install vim

### Tmux
brew install tmux
brew install tmuxp

### Yarn
# brew install yarn

### Zsh
brew install zsh
brew install zsh-syntax-highlighting
