#!/bin/bash

ROOT=$HOME
DIR="dotf"
DOTF="$ROOT/$DIR"

REPO_DIR="$ROOT/repos"

function check_or_create_config() {
	CONFIG_DIR="$HOME/.config"

	if [ ! -d $CONFIG_DIR ]; then
		mkdir $CONFIG_DIR
	fi
}

function check_or_create_repos() {
	if [ ! -d $REPO_DIR ]; then
		mkdir $REPO_DIR
	fi
}

function check_or_create_zsh_history {
	if [ ! -d $HOME/.cache/zsh ]; then
		mkdir -p $HOME/.cache/zsh
	fi

	touch $HOME/.cache/zsh/history
}


check_or_create_config
check_or_create_repos
check_or_create_zsh_history

### Repos
git clone $HOME git@github.com:alexjperkins/wiki.git
git clone $HOME git@github.com:sashajdn/dotf.git
git clone $HOME git@github.com:sashajdn/gogorithms.git
git clone $HOME git@github.com:sashajdn/rustgorithms.git
git clone $HOME git@github.com:sashajdn/roml.git
git clone $HOME git@github.com:sashajdn/pygos.git
git clone $HOME git@github.com:sashajdn/orderbook.git

### Zsh
ln -sf $DOTF/zsh/zshrc $HOME/.zshrc
ln -sf $DOTF/zsh/zprofile $HOME/.zprofile

### Alacritty
ln -sf $DOTF/config/alacritty $ROOT/.config

### Nvim
ln -sf $DOTF/nvim-lazy $DOTF/config
ln -sf $DOTF/config/nvim $ROOT/.config

### Neofetch
ln -sf $DOTF/config/neofetch $HOME/.config/neofetch
