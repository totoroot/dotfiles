{ config, lib, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/jam.txt";
    useSystemdActivation = true;
    secrets = {
      attic-client-env = {
        sopsFile = builtins.path {
          path = ../../../secrets/jam.yaml;
          name = "jam-secrets";
        };
        format = "yaml";
        key = "ATTICD_ENV";
        path = "/etc/atticd.env";
        owner = "root";
        mode = "0400";
      };
      nextcloud-exporter-token = {
        sopsFile = builtins.path {
          path = ../../../secrets/jam.yaml;
          name = "jam-secrets";
        };
        format = "yaml";
        key = "NEXTCLOUD_EXPORTER_TOKEN";
        path = "/var/secrets/nextcloud-exporter.token";
        owner = "nextcloud-exporter";
        group = "nextcloud-exporter";
        mode = "0400";
      };
      prometheus-home-assistant-token = {
        sopsFile = builtins.path {
          path = ../../../secrets/jam.yaml;
          name = "jam-secrets";
        };
        format = "yaml";
        key = "PROMETHEUS_HOME_ASSISTANT_TOKEN";
        path = "/var/secrets/prometheus-home-assistant.token";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
