alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

alias q=exit
alias clr=clear
alias please='sudo '
# alias rm='rm -I'
alias purge='rm -rf'
alias cp='rsync -a'
alias ccp='rsync -az'
alias pcp='rsync -azP'
alias rcp='rsync -vaP --delete'
alias rmirror='rsync -rtvu --delete'
alias mv='mv -v'
alias mkdir='mkdir -p'
alias wget='wget -c'
alias cat='bat -Pp'
alias find='fd'
alias replace='sd'

alias cdd='cd $XDG_CONFIG_HOME/dotfiles'
alias cds='cd /etc/nixos'

alias mk=make
alias gurl='curl --compressed'
alias vurl='curl -L -v'
alias disks='lsblk -o name,label,mountpoint,size,uuid'
alias ccd='(){ mkdir -p "$1"; cd "$1";}'

alias clipin='xclip -sel clip -i'
alias clipout='xclip -sel clip -o'

alias colorpick="print '\nPicking color in 5 seconds...\n' && sleep 5 && colorpicker --short --one-shot | tr -d '\n' | xclip -sel clip && xclip -sel clip -o"

# ugly yet beautiful...hacky for sure
alias viewdeps='(){ nix-env -iA nixos.$1 --dry-run ;}'
alias inst='(){ nix-env -iA nixos.$1 ;}'
alias viewinst='nix-env --query --installed'
alias remove='nix-env --uninstall'

# edit zshrc
alias zshconfig="$EDITOR ~/.zshrc"
# source zshrc
alias zshsource="source ~/.zshrc"
# alias to scan wireless network for connected devices
alias scan="sudo nmap -sn 192.168.8.0/24 | sed -e 's#.*for \(\)#\1#' | sed '/^Host/d' | sed '/MAC/{G;}'"
# find largest files in directory
alias ducks="sudo du -cks -- * | sort -rn | head"
# rm EXIF data from images in directory
alias rmexif='exiftool -all='

alias sc=systemctl
alias ssc='sudo systemctl'
alias sn="systemctl suspend"

alias ls="ls --color=auto --hyperlink=auto"
alias l="ls -1"
alias lg="ls -1 -g"

if command -v exa >/dev/null; then
  alias exa="exa --group-directories-first";
  alias lsc="exa";
  alias lc="exa -l";
  alias ll="exa -lg";
  alias la="LC_COLLATE=C exa -la";
fi

autoload -U zmv

take() {
  mkdir "$1" && cd "$1";
}; compdef take=mkdir

zman() {
  PAGER="less -g -I -s '+/^       "$1"'" man zshall;
}

beep() {
    sh -c '
    ( \speaker-test --frequency 800 --test sine > /dev/null 2>&1 )&
    BEEP_PID=$(pgrep speaker-test)
    \sleep 0.04s
    \kill -9 $BEEP_PID
    '
}

exists() {
  command -v "$1" >/dev/null 2>&1
}
