#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lht --color=auto'
alias lla='ls -laht --color=auto'
PS1='[\u@\h \W]\$ '
