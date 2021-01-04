#!/usr/bin/env zsh

g() { [[ $# = 0 ]] && git status --short . || git $*; }

alias git='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch -av'
alias gop='git open'
alias gbl='git blame'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit --all -m'
alias gca='git commit --amend'
alias gcf='git commit --fixup'
alias gcl='git clone'
alias gco='git checkout'
alias gcoo='git checkout --'
alias gd='git diff'
alias gf='git fetch'
alias gi='git init'
alias gl='git log --graph --pretty="format:%C(yellow)%h%Creset %C(red)%G?%Creset%C(green)%d%Creset %s %Cblue(%cr) %C(bold blue)<%aN>%Creset"'
alias gll='git log --pretty="format:%C(yellow)%h%Creset %C(red)%G?%Creset%C(green)%d%Creset %s %Cblue(%cr) %C(bold blue)<%aN>%Creset"'
alias gL='gl --stat'
alias gp='git push'
alias gpl='git pull --rebase --autostash'
alias gs='git status --short .'
alias gst='git status'
alias gsh='git stash'
alias gr='git reset HEAD'
alias grv='git rev-parse'
