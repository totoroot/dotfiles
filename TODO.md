## Open

- Replace greenclip with Wayland tools
    + Issue: greenclip is only compatible with X11, so it should be replaced with a suitable Wayland alternative
    - [ ] Remove greenclip config
    - [ ] Install Wayland clipboard tools
    - [ ] Adapt rofi clipmenu
    - [ ] Launch clipboard daemon with user session
- Install wluma for adjusting screen brightness
- Handle rofi errors
    + Handle errors when e.g. app was not found  with appmenu rofi script
- Auto-detect devices for scrutiny config
- Refine taskell keybindings
- Refine keybindings for hyprland compositor
- Install gparted
    + There seems to be an issue with launching it on Wayland
- Fix languagetool systemd errors
- Fix rofi bookmarkmenu
- Install screenshot utility on Wayland
- Rofi session switcher
- Switch to flake for Hyprland
- Add keyboard layout in Plasma with config
- Fix keyboardswitcher shell script
- Install Dracula KDE theme with NixOS config

## In Progress

- Fix rofi windowmenu
- Enable screen sharing on Wayland
    - [ ] Install and configure pipewire
    - [ ] Disable pulseaudio
    - [ ] Test OBS screen recording

## Completed

- Add Wayland menu bar
    + Install and configure a suitable replacement for polybar
    - [x] Find suitable replacement
    - [x] Theme menu bar
    - [x] Add clock
    - [x] Add appmenu
    - [x] Add powermenu
- Clear NVME SSD and move /home to it
- Create directories in /var/cache/ for pods
    + Directories in /var/cache/ should be automatically created with superuser permissions for each container name
- Fix hardware-accelerated video playback
- Install notification daemon on Wayland
- Theme hyprland windows
- Install inklingreader on NixOS
- Move promptconfig out of theme
