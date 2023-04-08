{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.polish;
in {
  options.modules.desktop.polish = {
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
