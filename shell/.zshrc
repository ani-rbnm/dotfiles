# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -Uz compinit; compinit
autoload -Uz promptinit; promptinit
# Autoloading custom functions. custom functions path added in ~/.zshenv
autoload -U ${fpath[1]}/*(:t)

# Module for menu-based completion options
zmodload -i zsh/complist

# Setting up history
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999

# Anirban - Aliases sourced from a separate file
[[ -f ~/.zaliases ]] && . ~/.zaliases

# Anirban - options in a separate file
[[ -f ~/.zoptions ]] && . ~/.zoptions

# Default keymap set to vi as opposed to the default emacs
bindkey -v

# Removing escape prefix in insert mode. cursor navigation won't work. Stephenson,p163
# This will make switching to command mode on ZLE faster
bindkey -rpM viins '\e'

# Enabling menu selection
zstyle ':completion:*' menu 'select=0'

# Enabling vi nav keys h,j,k,l in the menu. Modified by updating 'menuselect' keymap
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect '\C-o' accept-and-menu-complete
bindkey '\C-z' undo
# <Tab> or ^i bound to 'complete-word' instead of the old 'expand-or-complete'
bindkey '\C-i' complete-word
zstyle ':completion:*' completer _expand _complete _ignored
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

source ~/.config/extra-themes/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/.config/extra-packages/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pyenv setting
eval "$(pyenv init -)"

# Created by `pipx` on 2024-11-30 12:35:43
export PATH="$PATH:/home/anirban/.local/bin"
# Anirban - Adding pipx autocompletions
eval "$(register-python-argcomplete pipx)"
#Anirban - Adding the default pipx version which points to 3.13 in pyenv
export PIPX_DEFAULT_PYTHON=~/.pyenv/versions/3.13.0/bin/python3.13
# Anirban - adding nvim server listen address for zathura to work with tex
export NVIM_LISTEN_ADDRESS=/tmp/nvim-server
