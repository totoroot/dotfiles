{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.communication.discord;
in {
  options.modules.desktop.communication.discord = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # If not installed from the bleeding edge, Discord will sometimes
      # soft-lock itself on a "there's an update for discord" screen.
      discord
    ];
  };
}
