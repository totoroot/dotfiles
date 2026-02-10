{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.communication.telegram;
in {
  options.modules.desktop.communication.telegram = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      telegram-desktop
    ];
  };
}
