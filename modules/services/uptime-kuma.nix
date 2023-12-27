{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.uptime-kuma;
  uptimePort = 4042;
in
{
  options.modules.services.uptime-kuma = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      uptime-kuma = {
        enable = true;
        settings = {
          PORT = "${toString uptimePort}";
        };
        appriseSupport = false;
      };
    };

    environment.systemPackages = [ config.services.uptime-kuma.package ];
  };
}
