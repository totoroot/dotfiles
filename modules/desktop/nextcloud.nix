{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.nextcloud;
in {
  options.modules.desktop.nextcloud = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Nextcloud desktop client
      nextcloud-client
    ];
  };
}
