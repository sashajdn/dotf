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

### Zsh
ln -sf $DOTF/zsh/zshrc $HOME/.zshrc
ln -sf $DOTF/zsh/zprofile $HOME/.zprofile

### Nvim
ln -sf $DOTF/nvim/init.vim $HOME/.config/nvim/init.vim
ln -sf $DOTF/config/nvim $HOME/.config/nvim
ln -sf $DOTF/config/nvim $HOME/.config/nvimpager

nvim -c PlugInstall
nvim -c CocInstall coc-graphql coc-json coc-python coc-tsserver coc-yaml

### Cava
ln -sf $DOTF/config/cava $HOME/.config/cava

### Neofetch
ln -sf $DOTF/config/neofetch $HOME/.config/neofetch

### LF
ln -sf $DOTF/config/lf/ $HOME/.config/lf

### CoC
ln -sf $DOTF/config/coc $HOME/.config/coc

### Spotify
# ln -sf $DOTF/config/spotifyd $HOME/.config/spotifyd
# ln -sf $DOTF/config/spotify-tui $HOME/.config/spotify-tui

### Zathura
# ln -sf $DOTF/config/zathura $HOME/.config/zathura

### Vim
ln -sf $DOTF/vim/vimrc $HOME/.vimrc

### Repos
git clone $REPO_DIR git@github.com:alexjperkins/wiki.git

### FZF
/usr/local/opt/fzf/install

