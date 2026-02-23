{ config, lib, ... }:

let
  secretsFile = builtins.path {
    path = ../../../secrets/jam.yaml;
    name = "jam-secrets";
  };
  mkSecret = { key, path, owner ? "root", group ? "root", mode ? "0400", format ? "yaml" }: {
    sopsFile = secretsFile;
    inherit key path owner mode format;
  } // lib.optionalAttrs (group != null) { inherit group; };
in
{
  sops = {
    age.keyFile = "/var/lib/sops-nix/jam.txt";
    useSystemdActivation = true;
    secrets = {
      attic-client-env = mkSecret {
        key = "ATTICD_ENV";
        path = "/etc/atticd.env";
      };
      nextcloud-exporter-token = mkSecret {
        key = "NEXTCLOUD_EXPORTER_TOKEN";
        path = "/var/secrets/nextcloud-exporter.token";
        owner = "nextcloud-exporter";
        group = "nextcloud-exporter";
      };
      prometheus-home-assistant-token = mkSecret {
        key = "PROMETHEUS_HOME_ASSISTANT_API_TOKEN";
        path = "/var/secrets/prometheus-home-assistant.token";
      };
    };
  };
}
