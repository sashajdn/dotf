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
ln -sf $HOME/.zshrc $DOTF/zsh/zshrc 
ln -sf $HOME/.zprofile $DOTF/zsh/zprofile 

### Nvim
ln -sf $HOME/.config/nvim/init.vim $DOTF/nvim/init.vim 
ln -sf $HOME/.config/nvim $DOTF/config/nvim 
ln -sf $HOME/.config/nvimpager $DOTF/config/nvim 

nvim -c PlugInstall
nvim -c CocInstall coc-graphql coc-json coc-python coc-tsserver coc-yaml

### Cava
ln -sf $HOME/.config/cava $DOTF/config/cava 

### Neofetch
ln -sf $HOME/.config/neofetch $DOTF/config/neofetch 

### LF
ln -sf $HOME/.config/lf $DOTF/config/lf/ 

### CoC
ln -sf $HOME/.config/coc $DOTF/config/coc 

### Spotify
# ln -sf $DOTF/config/spotifyd $HOME/.config/spotifyd
# ln -sf $DOTF/config/spotify-tui $HOME/.config/spotify-tui

### Zathura
# ln -sf $DOTF/config/zathura $HOME/.config/zathura

### Vim
ln -sf $HOME/.vimrc $DOTF/vim/vimrc 

### Repos
git clone $REPO_DIR git@github.com:alexjperkins/wiki.git

### FZF
/usr/local/opt/fzf/install
