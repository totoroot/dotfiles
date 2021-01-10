# Move in prompt with <Ctrl>/<Alt> + <Left>/<Right>
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;5D' beginning-of-line
bindkey '^[[1;5C' end-of-line

# Move in prompt with <Home> and <End>
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Delete rest of prompt with <Ctrl> + <Backspace>/<Delete>
bindkey '^H' backward-kill-line
bindkey '^[[3;5~' vi-kill-eol

# Delete previous/next word with <Alt> + <Backspace>/<Delete>
# bindkey '' backward-kill-word Already bound to ?
bindkey '^[[3;3~' kill-word

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
