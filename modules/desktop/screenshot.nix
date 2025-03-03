# modules/desktop/screenshot.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.screenshot;
in {
  options.modules.desktop.screenshot = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # X screenshot utility
      maim
      # Selection tool for screenshot scripts
      # hacksaw
      # Powerful yet simple to use screenshot software
      flameshot
      # KDE Plasma screenshot tool
      kdePackages.spectacle
      # Grab images from a Wayland compositor
      grim
      # Select a region in a Wayland compositor
      slurp
      # Wayland native snapshot editing tool, inspired by Snappy on macOS
      swappy
    ];
  };
}
