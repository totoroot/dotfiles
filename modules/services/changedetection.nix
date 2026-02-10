{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.changedetection;
  domain = "xn--berwachungsbehr-mtb1g.de";
  changedetectionPort = 5002;
in
{
  options.modules.services.changedetection = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.changedetection-io = {
      enable = true;
      port = changedetectionPort;
      behindProxy = true;
      user = "changedetection";
      group = "changedetection";
      datastorePath = "/var/lib/changedetection";
      listenAddress = "0.0.0.0";
      baseURL = "website.${domain}";
      environmentFile = "/var/secrets/changedetection.env";
    };

    users = {
      groups."changedetection" = { };
      users."changedetection" = {
        name = "changedetection";
        group = "changedetection";
        isSystemUser = true;
      };
    };

    user.extraGroups = [ "changedetection" ];

    # Figure out why exposing the port only to tailscale0 interface does not work
    networking.firewall.allowedTCPPorts = [ changedetectionPort ];
  };
}
