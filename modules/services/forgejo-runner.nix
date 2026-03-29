{ options, config, lib, ... }:

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
    users.groups.gitea-runner = { };

    users.users.gitea-runner = {
      isSystemUser = true;
      group = "gitea-runner";
      home = "/var/lib/gitea-runner";
      createHome = true;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/gitea-runner 0750 gitea-runner gitea-runner -"
      "d /var/lib/gitea-runner/codeberg 0750 gitea-runner gitea-runner -"
    ];

    services.gitea-actions-runner.instances.codeberg = {
      enable = true;
      inherit (cfg) name url tokenFile;
      labels = cfg.labels;
    };
  };
}
