{ config, lib, ... }:

let
  secretsFile = builtins.path {
    path = ../../../secrets/violet.yaml;
    name = "violet-secrets";
  };
  mkSecret = { key, path, owner ? "root", group ? "root", mode ? "0400", format ? "yaml" }: {
    sopsFile = secretsFile;
    inherit key path owner mode format;
  } // lib.optionalAttrs (group != null) { inherit group; };
in
{
  sops = {
    age.keyFile = "/var/lib/sops-nix/violet.txt";
    useSystemdActivation = true;
    secrets = {
      attic-client-env = mkSecret {
        key = "ATTICD_ENV";
        path = "/etc/atticd.env";
      };
      immich-exporter-env = mkSecret {
        key = "IMMICH_API_TOKEN";
        path = "/var/secrets/immich-exporter.env";
      };
      immich-db = mkSecret {
        key = "DB_PASSWORD";
        path = "/var/secrets/immich";
      };
    };
  };
}
