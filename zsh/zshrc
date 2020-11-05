### --- Keanu ZSH config --- ###


## neofetch
neofetch

## Enable colours
autoload -U colors && colors


### --- VCS --- ###
## Preload VCS
autoload -Uz vcs_info
precmd() { vcs_info }

## Format VCS info
zstyle ':vcs_info:git:*' formats '%b'

### --- Prompt --- ###
# Prompt
setopt PROMPT_SUBST
NEWLINE=$'\n'
PROMPT='[%B%F{169}%n%f%b%B%F{38}@%f%b%F{169}%M%f %B%F{38}${PWD/#$HOME/~}%f%b] %B%F{1}${vcs_info_msg_0_}%f%b${NEWLINE}%B%F{38}$%f%b '


### --- History --- ###
## History in cache directory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

### --- Completion --- ###
## Basic auto/tab complete, gives tab completion menu
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)  # include hidden files

### --- LS Colours --- ###

### --- Vi --- ###
## Vi Mode
bindkey -v
export KEYTIMEOUT=1

## Vi bindings for complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

## Edit cmd with vim, with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

## Vi cursor change mode dependent
function zle-keymap-select {
	if [[ ${KEYMAP} == vicmd ]] ||
	   [[ $1 = 'block' ]]; then
		echo -ne '\e[1 q'
	elif [[ ${KEYMAP} ==  viins ]] ||
             [[ ${KEYMAP} == '' ]] ||
	     [[ $1 = 'beam' ]]; then
		echo -ne '\e[5 q'
	fi
}
zle -N zle-keymap-select
zle-line-init(){
	zle -K viins  # instantiate `vi insert` as keymap 
	echo -ne '\e[5 q'
}
zle -N zle-line-init
echo -n '\e[5 q'  # Use beam shape cursor on startup
preexec() { echo -ne '\e[5 q' ;}  # Use beam cursor for each new prompt


### --- LF --- ###
## LF to switch dirs, bind to ctrl-o
lfcd () {
	tmp="$(mktemp)"
	lf -last-dir-path="$tmp" "$@"
	if [ -f "$tmp" ]; then 
		dir="$(cat "$tmp")"
		rm -f "$tmp"
		[ -d "$dir" ] && [ "$dir" !="$(pwd)" ] && cd "$dir"
	fi
}
bindkey -s '^o' 'lfcd\n'

### --- NVM --- ###
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

### --- Aliases --- ###
# Load aliases if exist
[ -f "$HOME/keanu/zsh/aliasrc" ] && source "$HOME/keanu/zsh/aliasrc"
[ -f "$HOME/.aliasrc" ] && source "$HOME/.aliasrc"

### --- Environment --- ###
[ -f "$HOME/keanu/environments/keanu.env" ] && source "$HOME/keanu/environments/keanu.env"
[ -f "$HOME/keanu/zsh/zshenv" ] && source "$HOME/keanu/zsh/zshenv"
[ -f "$HOME/keanu/.env" ] && source "$HOME/keanu/.env"

### --- Kubernetes --- ###
source <(kubectl completion zsh)
complete -F __start_kubectl kc

### --- BAT --- ###
export BAT_THEME="ansi-dark"


### --- FZF --- ###
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh


### --- Syntax highlighting (should be last) --- ###
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2> /dev/null
