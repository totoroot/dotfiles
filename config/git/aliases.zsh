#!/usr/bin/env zsh

alias g='() { [[ $# = 0 ]] && git status --short . || git $*; }'
alias git='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch -av'
alias gop='git open'
alias gbD='git branch -D'
alias gbl='git blame'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcn!='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcm='git commit -m'
alias gcam='git commit --all -m'
alias gca='git commit --amend'
alias gcf='git commit --fixup'
alias gcl='git clone'
alias gclv='git -c core.sshCommand="ssh -v" clone'
alias gco='git checkout'
alias gcoo='git checkout --'
alias gd='git diff'
alias gf='git fetch'
alias gi='git init'
alias gl='git log --graph --pretty="format:%C(yellow)%h%Creset %C(red)%G?%Creset%C(green)%d%Creset %s %Cblue(%cr) %C(bold blue)<%aN>%Creset"'
alias gli='gitlint --config ~/.config/gitlint/default.ini --commits HEAD'
alias gll='git log --pretty="format:%C(yellow)%h%Creset %C(red)%G?%Creset%C(green)%d%Creset %s %Cblue(%cr) %C(bold blue)<%aN>%Creset"'
alias glo='() {
    if (( $1 )); then
        git log --oneline --format="%s" | head -n $1
    else
        git log --oneline --format="%s"
    fi
}'
alias gloh='() {
    if (( $1 )); then
        git log --oneline --pretty="format:%C(yellow)%h%Creset %s" | head -n $1
    else
        git log --oneline --pretty="format:%C(yellow)%h%Creset %s"
    fi
}'
alias gL='gl --stat'
alias gp='git push'
alias gpf!='git push --force'
alias gpl='git pull --rebase --autostash'
alias gr='git reset HEAD'
alias grb='git rebase -i'
alias gri='(){ git rebase -i HEAD~$1 }'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grst='git restore'
alias grsts='git restore --staged'
alias grv='git rev-parse'
alias gss='git status --short .'
alias gsh='git show'
alias gst='git status'
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstall='git stash --all'
alias gsu='git submodule update'
alias gu='git fetch && git rebase origin/main'
