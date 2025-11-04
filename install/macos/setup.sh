#!/bin/bash

ROOT=$HOME
DOTF_DIR="dotf"
DOTF="$ROOT/$DOTF_DIR"
WIKI_DIR="wiki"
WIKI="$ROOT/$WIKI_DIR"
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
git clone $REPO_DIR git@github.com:alexjperkins/wiki.git
git clone $REPO_DIR git@github.com:sashajdn/dotf.git
git clone $REPO_DIR git@github.com:sashajdn/gogorithms.git
git clone $REPO_DIR git@github.com:sashajdn/rustgorithms.git
git clone $REPO_DIR git@github.com:sashajdn/roml.git
git clone $REPO_DIR git@github.com:sashajdn/pygos.git
git clone $REPO_DIR git@github.com:sashajdn/orderbook.git
git clone $REPO_DIR git@github.com:sashajdn/intervention.git
git clone $REPO_DIR git@github.com:sashajdn/sushidog.git

### Zsh
ln -sf $DOTF/zsh/zshrc $HOME/.zshrc
ln -sf $DOTF/zsh/zprofile $HOME/.zprofile

### Nvim
ln -sf $DOTF/nvim $DOTF/config

### Neofetch
ln -sf $DOTF/config $HOME/.config
