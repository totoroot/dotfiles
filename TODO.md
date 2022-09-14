## Open

- Replace greenclip with Wayland tools
    + Issue: greenclip is only compatible with X11, so it should be replaced with a suitable Wayland alternative
    - [ ] Remove greenclip config
    - [ ] Install Wayland clipboard tools
    - [ ] Adapt rofi clipmenu
    - [ ] Launch clipboard daemon with user session
- Auto-detect devices for scrutiny config
- Refine taskell keybindings
- Refine keybindings for hyprland compositor
- Theme hyprland windows
- Install gparted
    + There seems to be an issue with launching it on Wayland
- Fix languagetool systemd errors
- Fix rofi bookmarkmenu
- Fix rofi windowmenu
- Install screenshot utility on Wayland
- Install notification daemon on Wayland

## In Progress


## Completed

- Clear NVME SSD and move /home to it
- Add Wayland menu bar
    + Install and configure a suitable replacement for polybar
    - [x] Find suitable replacement
    - [x] Theme menu bar
    - [x] Add clock
    - [x] Add appmenu
    - [x] Add powermenu
- Create directories in /var/cache/ for pods
    + Directories in /var/cache/ should be automatically created with superuser permissions for each container name
- Fix hardware-accelerated video playback
