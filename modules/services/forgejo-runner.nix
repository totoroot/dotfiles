{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.forgejo-runner;
in
{
  options.modules.services.forgejo-runner = {
    enable = mkBoolOpt false;

    name = mkOpt types.str "forgejo-runner-codeberg";
    url = mkOpt types.str "https://codeberg.org";
    tokenFile = mkOpt types.str "/var/secrets/forgejo-runner-codeberg.token";
    labels = mkOpt (types.listOf types.str) [ "native:host" ];
  };

  config = mkIf cfg.enable {
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.codeberg = {
        enable = true;
        inherit (cfg) name url tokenFile labels;
      };
    };
  };
}
