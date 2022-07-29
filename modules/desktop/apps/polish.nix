# modules/desktop/apps/polish.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.polish;
in {
  options.modules.desktop.apps.polish = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Simple, fast and easy to use app to remove unnecessary files from your computer
      czkawka
      # Simple but powerful and fast bulk file renamer
      szyszka
    ];
  };
}
