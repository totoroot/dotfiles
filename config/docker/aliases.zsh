alias dk=docker
alias dkc=docker-compose
alias dkm=docker-machine
alias dkl='dk logs'
alias dkcl='dkc logs'
alias dps='docker ps'
alias dockerstat='docker stats --no-stream'

dkclr() {
  dk stop $(docker ps -a -q)
  dk rm $(docker ps -a -q)
}

dke() {
  dk exec -it "$1" "${@:1}"
}
