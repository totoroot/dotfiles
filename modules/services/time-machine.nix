# Based on [this article](https://grahamc.com/blog/timemachine-backups-linux-nixos/) by Graham Christensen

{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.time-machine;
in
{
  options.modules.services.time-machine = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      netatalk = {
        enable = true;
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = false;
        publish = {
          enable = true;
          userServices = true;
        };
      };
    };

    # Open firewall for netatalk
    # TODO Only open the port for local network
    networking.firewall.allowedTCPPorts = [
      548
    ];
  };
}
