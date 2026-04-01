{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.alloy;
in
{
  options.modules.services.alloy = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.alloy = {
      enable = true;
      configPath = pkgs.writeText "alloy-config.alloy" ''
        loki.write "default" {
          endpoint {
            url = "http://127.0.0.1:3100/loki/api/v1/push"
          }
        }

        loki.source.journal "systemd" {
          max_age    = "24h"
          forward_to = [loki.write.default.receiver]
          labels = {
            job  = "systemd-journal"
            host = "${config.networking.hostName}"
          }
        }
      '';
    };

    systemd.services.alloy.after = [ "loki.service" ];
    systemd.services.alloy.wants = [ "loki.service" ];
  };
}
