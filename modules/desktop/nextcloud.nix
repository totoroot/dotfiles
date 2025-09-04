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

    services.davfs2 = {
      enable = true;
      settings = {
        globalSection = {
          use_locks = true;
        };
        sections = {
          "/home/mathym/Desktop/nextcloud-matthias-webdav" = {
            gui_optimize = true;
          };
        };
      };
    };

    user.extraGroups = [ "davfs2" ];
  };
}
