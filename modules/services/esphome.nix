{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.esphome;
  version = "2026.1";
  port = 6052;
in
{
  options.modules.services.esphome = {
    enable = mkBoolOpt false;
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
          "/var/cache/esphome/config:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        # extraOptions = [
        # "--device=/dev/ttyUSB0"
        # "--device=/dev/ttyACM0"
        # ];
        environment = {
          ESPHOME_DASHBOARD_USE_PING = "true";
        };
        autoStart = true;
      };
    };

    user.extraGroups = [ "dialout" ];

    systemd.services.docker-esphome.serviceConfig = {
      User = "mathym";
      Group = "docker";
      CacheDirectory = "esphome";
      CacheDirectoryMode = "0750";
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

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ config.services.esphome.port ];
  };
}
