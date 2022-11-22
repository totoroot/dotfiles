# modules/desktop/clipboard.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.clipboard;
in {
  options.modules.desktop.clipboard = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Simple clipboard manager to be integrated with rofi
      haskellPackages.greenclip
      # Command-line copy/paste utilities for Wayland
      wl-clipboard
      # A wrapper to use wl-clipboard as a drop-in replacement for X11 clipboard tools
      wl-clipboard-x11
      # Wayland clipboard manager
      cliphist
      # A simple clipboard manager for Wayland
      clipman
      # xdotool type for wayland
      wtype
      # A launcher/menu program for wlroots based wayland compositors such as sway
      wofi
      # Simple emoji selector for Wayland using wofi and wl-clipboard
      wofi-emoji
    ];

    home.configFile = {
      "greenclip.toml".source = "${configDir}/greenclip/greenclip.toml";
    };

    environment.shellAliases = {
      clip = "greenclip print | sed '/^$/d' | fzf -e | xargs -r -d'\n' -I '{}' greenclip print '{}'";
    };
  };
}
