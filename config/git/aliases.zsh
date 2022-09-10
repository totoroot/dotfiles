#!/usr/bin/env zsh

# Very concise ´git status´ or short for ´git ...´
alias g='() {
    [[ $# = 0 ]] && git status --short . || git $*;
}'
# Stage untracked or modified files and directories
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
# Show local and remote branchs with latest commit
alias gb='git branch -av'
alias gop='git open'
alias gbD='git branch -D'
alias gbl='git blame'
alias gc='git commit -v'
alias gca='git commit -v --amend'
alias gcn='git commit -v --amend --no-edit'
alias gcall='git commit -v --all'
alias gcaall='git commit -v --all --amend'
alias gcan='git commit -v -all --amend --no-edit'
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
# Very concise commit log with optional limit
alias glo='() {
    if (( $1 )); then
        git log --oneline --format="%s" | head -n $1
    else
        git log --oneline --format="%s"
    fi
}'
# Same as ´glo´ but with short commit hashes
alias gloh='() {
    if (( $1 )); then
        git log --oneline --pretty="format:%C(yellow)%h%Creset %s" | head -n $1
    else
        git log --oneline --pretty="format:%C(yellow)%h%Creset %s"
    fi
}'
# Commit log with commit stats (added and removed lines)
alias gL='gl --stat'
alias gr='git reflog'
# Reflog in the style of ´git log´
alias glg='git log -g'
alias gp='git push'
# Push feature branch to remote and set upstream
alias gpb='() {
    git push --set-upstream origin $(git branch --show-current)
}'
alias gpf!='git push --force'
alias gpl='git pull --rebase --autostash'
# Prune local branches
alias gprlb='git fetch -p ; git branch -r | awk "{print $1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print $1}" | xargs git branch -d'
# Prune remote branches
alias gprrb='() {
    git remote prune $(git remote)
}'
alias grh='git reset HEAD'
# Interactive rebase
alias grb='git rebase -i'
# Interactive rebase for x latest commits
alias gri='() {
    git rebase -i HEAD~$1
}'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grst='git restore'
alias grsts='git restore --staged'
alias grv='git rev-parse'
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
# Fetch remote changes and rebase local branch to remote main/master branch
alias gu='() {
    git fetch
    if $(git branch --remotes | grep -q "^  $(git remote)/main"); then                                 ~/dev/private/dotfiles
        git rebase $(git remote)/main
    else
        git rebase $(git remote)/master
    fi
}'
