#!/bin/bash


ROOT=$HOME
DIR="dotf"

DOTF="$ROOT/$DIR"


function check_or_create_config(){

	CONFIG_DIR="$HOME/.config"

	if [ ! -d CONFIG_DIR ]; then
		mkdir CONFIG_DIR
	fi
}


check_or_create_config


# DOTF
ln -sf $DOTF/nvim/init.vim $DOTF/.config/nvim/init.vim
ln -sf $DOTF/config/nvim $HOME/.config/nvim

# ZSH
ln -sf $DOTF/zsh/.zshrc $HOME/.zshrc
ln -sf $DOTF/zsh/.zprofile $HOME/.zprofile

# CAVA
ln -sf $DOTF/config/cava $HOME/.config/cava

# NEOFETCH
ln -sf $DOTF/config/neofetch $HOME/.config/neofetch

# COC
ln -sf $DOTF/config/coc $HOME/.config/coc

# SPOTIFY
ln -sf $DOTF/config/spotifyd $HOME/.config/spotifyd
ln -sf $DOTF/config/spotify-tui $HOME/.config/spotify-tui

## TMUX
ln -sf $DOTF/config/tmuxp/ $HOME/.config/tmuxp

# ZATHURA
ln -sf $DOTF/config/zathura $HOME/.config/zathura
