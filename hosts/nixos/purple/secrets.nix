{ config, lib, ... }:

{
  sops = {
    age.keyFile = "/var/lib/sops-nix/purple.txt";
    useSystemdActivation = true;
    secrets = {
      attic-client-env = {
        sopsFile = builtins.path {
          path = ../../../secrets/purple.yaml;
          name = "purple-secrets";
        };
        format = "yaml";
        key = "ATTICD_ENV";
        path = "/etc/atticd.env";
        owner = "root";
        mode = "0400";
      };
    };
  };
}
