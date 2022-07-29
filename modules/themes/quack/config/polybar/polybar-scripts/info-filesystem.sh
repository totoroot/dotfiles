#!/bin/sh

case "$1" in
    --clean)
        nix-collect-garbage --delete-old
        ;;
    --details)
        dunstify "Disk Usage" "$(duf -style=ascii)" -u normal -t 30000
        ;;
    *)
        df --output=avail / -h | tail -n 1 | sed 's/ //g'
        ;;
esac
