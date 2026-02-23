{ config, lib, ... }:

let
  secretsFile = builtins.path {
    path = ../../../secrets/purple.yaml;
    name = "purple-secrets";
  };
  mkSecret = { key, path, owner ? "root", group ? "root", mode ? "0400", format ? "yaml" }: {
    sopsFile = secretsFile;
    inherit key path owner mode format;
  } // lib.optionalAttrs (group != null) { inherit group; };
in
{
  sops = {
    age.keyFile = "/var/lib/sops-nix/purple.txt";
    useSystemdActivation = true;
    secrets = {
      attic-client-env = mkSecret {
        key = "ATTICD_ENV";
        path = "/etc/atticd.env";
      };
    };
  };
}
