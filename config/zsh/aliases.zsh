alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

alias q=exit
alias clr=clear
alias sudo='sudo '
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias wget='wget -c'
alias cat='bat -Pp'

alias mk=make
alias rcp='rsync -vaP --delete'
alias rmirror='rsync -rtvu --delete'
alias gurl='curl --compressed'

alias y='xclip -selection clipboard -in'
alias p='xclip -selection clipboard -out'

# edit zshrc
alias zshconfig="$EDITOR ~/.zshrc"
# source zshrc
alias zshsource="source ~/.zshrc"
# alias to scan wireless network for connected devices
alias scan="sudo nmap -sn 192.168.8.0/24 | sed -e 's#.*for \(\)#\1#' | sed '/^Host/d' | sed '/MAC/{G;}'"
# find largest files in directory
alias ducks="sudo du -cks -- * | sort -rn | head"
# set python3 as standard python interpreter
alias python='/usr/bin/python3'
# rm EXIF data from images in directory
alias rmexif='exiftool -all='


alias sc=systemctl
alias ssc='sudo systemctl'

if command -v exa >/dev/null; then
  alias exa="exa --group-directories-first";
  alias l="exa -1";
  alias ll="exa -lg";
  alias la="LC_COLLATE=C exa -la";
fi

autoload -U zmv

take() {
  mkdir "$1" && cd "$1";
}; compdef take=mkdir

zman() {
  PAGER="less -g -s '+/^       "$1"'" man zshall;
}

r() {
  local time=$1; shift
  sched "$time" "notify-send --urgency=critical 'Reminder' '$@'; ding";
}; compdef r=sched
