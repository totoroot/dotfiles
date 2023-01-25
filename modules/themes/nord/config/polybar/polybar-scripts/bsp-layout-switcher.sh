#!/bin/sh

FOCUSED_DESKTOP=$(bspc query -D -d 'focused' --names)

case "$1" in
    --previous)
        bsp-layout previous "${FOCUSED_DESKTOP}" --layouts tiled,tall,rtall,grid
        bsp-layout set $(bsp-layout get "${FOCUSED_DESKTOP}") "${FOCUSED_DESKTOP}"
        ;;
    --next)
        bsp-layout next "${FOCUSED_DESKTOP}" --layouts tiled,tall,rtall,grid
        bsp-layout set $(bsp-layout get "${FOCUSED_DESKTOP}") "${FOCUSED_DESKTOP}"
        ;;
    --reload)
        bsp-layout reload "${FOCUSED_DESKTOP}"
        ;;
    --remove)
        bsp-layout remove "${FOCUSED_DESKTOP}"
        ;;
    *)
        bsp-layout get "${FOCUSED_DESKTOP}"
        ;;
esac
