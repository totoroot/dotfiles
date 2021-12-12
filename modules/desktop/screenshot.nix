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
      unstable.hacksaw

      # Powerful yet simple to use screenshot software
      unstable.flameshot

      # KDE Plasma screenshot tool
      spectacle
    ];
  };
}
