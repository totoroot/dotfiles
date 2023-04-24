#!/usr/bin/env zsh

set -e

cd ~/.config/dotfiles
git remote remove origin
git remote add origin git@codeberg.org:totoroot/dotfiles.git
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/$HOST"
echo ""
cat "$HOME/.ssh/$HOST.pub"
printf "\nHave you added the key to Codeberg:\nhttps://codeberg.org/user/settings/keys"

while true; do
  read "Yes or no? [y/n]: " yn
    case $yn in
      [Yy]*) return 0  ;;
      [Nn]*) echo "Aborted" ; return  1 ;;
    esac
done

git fetch origin
git branch --set-upstream-to=origin/main main
