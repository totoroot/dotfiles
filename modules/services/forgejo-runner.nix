{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.forgejo-runner;
in
{
  options.modules.services.forgejo-runner = {
    enable = mkBoolOpt false;

    name = mkOpt types.str "jam-codeberg-runner";
    url = mkOpt types.str "https://codeberg.org";
    tokenFile = mkOpt types.str "/var/secrets/forgejo-runner-codeberg.token";

    labels = mkOpt (types.listOf types.str) [ "native:host" ];
  };

  config = mkIf cfg.enable {
    services.gitea-actions-runner.instances.codeberg = {
      enable = true;
      inherit (cfg) name url tokenFile;
      labels = cfg.labels;
    };
  };
}
