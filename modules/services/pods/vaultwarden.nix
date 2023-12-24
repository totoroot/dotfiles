{ options, config, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.pods.vaultwarden;
in {
  options.modules.services.pods.vaultwarden = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "docker";
      containers."vaultwarden" = {
        autoStart = true;
        image = "vaultwarden/server:latest";
        ports = [
          "8222:8082"
        ];
        volumes = [
          "/var/cache/vaultwarden:/data"
        ];
        environment = {
          WEBSOCKET_ENABLED = "true";
          ROCKET_PORT = "8082";
        };
      };
    };
    systemd.services.docker-vaultwarden.serviceConfig = {
      User = "mathym";
      Group = "docker";
      CacheDirectory = "vaultwarden";
      CacheDirectoryMode = "0750";
    };
  };
}
