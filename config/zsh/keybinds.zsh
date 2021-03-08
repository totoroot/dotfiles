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

# Vim's C-x C-l in zsh
history-beginning-search-backward-then-append() {
  zle history-beginning-search-backward
  zle vi-add-eol
}
zle -N history-beginning-search-backward-then-append
bindkey -M viins '^x^l' history-beginning-search-backward-then-append

# Open current prompt in external editor
autoload -Uz edit-command-line; zle -N edit-command-line
bindkey '^E' edit-command-line

# Fuzzy history search on <Ctrl> + <F>
fuzzy-hist() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac --height "30%" | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}
zle -N fuzzy-hist
bindkey '^F' fuzzy-hist
