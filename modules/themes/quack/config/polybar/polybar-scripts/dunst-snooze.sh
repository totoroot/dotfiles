#!/bin/sh

case "$1" in
    --toggle)
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
