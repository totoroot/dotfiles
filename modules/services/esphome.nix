{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.esphome;
  version = "2026.2";
  port = 6052;
in
{
  options.modules.services.esphome = with types; {
    enable = mkBoolOpt false;
    environment = mkOpt (attrsOf str) { };
    openFirewall = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "docker";
      containers."esphome" = {
        image = "ghcr.io/esphome/esphome:${version}";
        ports = [
          "${toString port}:${toString port}"
        ];
        volumes = [
          "/var/lib/esphome/config:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        # extraOptions = [
        #   "--device=/dev/ttyUSB1"
        # ];
        environment = {
          ESPHOME_DASHBOARD_USE_PING = "true";
        } // cfg.environment;
        autoStart = true;
      };
    };

    systemd.services.docker-esphome.serviceConfig = {
      User = "mathym";
      Group = "docker";
      StateDirectory = "esphome";
      StateDirectoryMode = "0750";
    };

    # See https://github.com/NixOS/nixpkgs/issues/275679 for more information of why I'm not using the NixOS esphome module for now

    # services = {
    #   esphome = {
    #     enable = true;
    #     port = 6052;
    #     address = "0.0.0.0";
    #   };
    # };

    environment.systemPackages = [ config.services.esphome.package ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      mkIf cfg.openFirewall [ config.services.esphome.port ];
  };
}
