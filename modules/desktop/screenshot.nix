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
      maim              # X screenshot utility
      unstable.hacksaw  # selection tool for screenshot scripts
    ];
  };
}
