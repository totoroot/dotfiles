{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.tailscale;
in
{
  options.modules.services.tailscale = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      tailscale = {
        enable = true;
      };
    };
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
