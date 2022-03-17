#!/bin/sh

case "$1" in
    --toggle)
        if [ "$(dunstctl is-paused)" = "true" ]; then
            notify-send -u low "Notifications turned on"
        fi
        dunstctl set-paused toggle
        ;;
    *)
        if [ "$(dunstctl is-paused)" = "true" ]; then
            echo "off"
        else
            echo "on"
        fi
        ;;
esac
