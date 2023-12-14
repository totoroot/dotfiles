{ options, config, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.jellyfin;
in {
  options.modules.services.jellyfin = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      jellyfin = {
        enable = true;
        openFirewall = true;
      };
      jellyseerr.enable = true;
    };

    user.extraGroups = [ "jellyfin" ];
  };
}
