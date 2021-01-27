#!/usr/bin/env zsh

pkill -u $UID -x polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

export MONITORS=( $(xrandr -q | grep ' connected' | cut -d' ' -f1) )

polybar main >$XDG_DATA_HOME/polybar.log 2>&1 &
echo 'Polybar launched...'
