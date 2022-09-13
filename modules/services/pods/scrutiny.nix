{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.pods.scrutiny;
in {
  options.modules.services.pods.scrutiny = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "docker";
      containers."scrutiny" = {
        autoStart = true;
        image = "ghcr.io/analogj/scrutiny:master-omnibus";
        ports = [
          # scrutiny webapp
          "8097:8080"
          # InfluxDB admin panel
          "8096:8086"
        ];
        volumes = [
          "/var/cache/scrutiny/config:/opt/scrutiny/config"
          "/var/cache/scrutiny/influxdb:/opt/scrutiny/influxdb"
          "/run/udev:/run/udev:ro"
        ];
        extraOptions = [
          "--cap-add"
          "SYS_RAWIO"
          "--cap-add"
          "SYS_ADMIN"
          "--device=/dev/nvme0"
          "--device=/dev/nvme1"
          "--device=/dev/sda"
          "--device=/dev/sdb"
          "--device=/dev/sdc"
        ];
      };
    };
    systemd.services.docker-scrutiny.serviceConfig = {
      User = "mathym";
      Group = "docker";
      CacheDirectory = "scrutiny";
      CacheDirectoryMode = "0750";
    };
  };
}
