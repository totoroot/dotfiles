# modules/desktop/apps/nextcloud.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.nextcloud;
in {
  options.modules.desktop.apps.nextcloud = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      unstable.nextcloud-client
    ];
  };
}
