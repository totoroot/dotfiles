{ config, lib, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/violet.txt";
    useSystemdActivation = true;
    secrets = {
      attic-client-env = {
        sopsFile = builtins.path {
          path = ../../../secrets/violet.yaml;
          name = "violet-secrets";
        };
        format = "yaml";
        key = "ATTICD_ENV";
        path = "/etc/atticd.env";
        owner = "root";
        mode = "0400";
      };
      immich-exporter-env = {
        sopsFile = builtins.path {
          path = ../../../secrets/violet.yaml;
          name = "violet-secrets";
        };
        format = "yaml";
        key = "IMMICH_API_TOKEN";
        path = "/var/secrets/immich-exporter.env";
        owner = "root";
        group = "root";
        mode = "0400";
      };
      immich-db = {
        sopsFile = builtins.path {
          path = ../../../secrets/violet.yaml;
          name = "violet-secrets";
        };
        format = "yaml";
        key = "DB_PASSWORD";
        path = "/var/secrets/immich";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
