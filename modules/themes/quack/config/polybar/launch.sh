#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar
polybar -c ~/.config/dotfiles/modules/themes/quack/config/polybar/config-primary.ini primary >$XDG_DATA_HOME/polybar.log 2>&1 &
echo 'Polybar launched...'

# Launch polybar systray
polybar -c ~/.config/dotfiles/modules/themes/quack/config/polybar/config-primary.ini systray >$XDG_DATA_HOME/systray.log 2>&1 &
echo 'Systray launched...'

#-c ~/.config/dotfiles/modules/themes/quack/config/polybar/config-primary.ini
