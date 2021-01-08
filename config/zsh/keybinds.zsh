# <Ctrl>/<Alt> + <Left>/<Right>
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;5D' beginning-of-line
bindkey '^[[1;5C' end-of-line
# bindkey '^[[3;3~' forward delete word
bindkey '^[[3;5~' kill-eol
bindkey '^H' backward-kill-line

# C-z to toggle current process (background/foreground)
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Open current prompt in external editor
autoload -Uz edit-command-line; zle -N edit-command-line
bindkey '^E' edit-command-line

# bind UP and DOWN arrow keys

# TODO fix zsh-history-substring-search
# zle -N history-substring-search-up
# bindkey '^[[A' history-substring-search-up
# zle -N history-substring-search-down
# bindkey '^[[B' history-substring-search-down

# fuzzy finder on <Ctrl> + <F>
# zle -N fzf
# bindkey '^F' fzf
