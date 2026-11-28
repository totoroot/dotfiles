{ config, lib, ... }:

let
  cfg = config.modules.services.gramps-web.postgresql;
in
{
  modules.services.gramps-web = {
    enable = true;
    postgresql = {
      # Enable only after taking the SQLite backup and provisioning credentials.
      enable = false;
      environmentFile = config.sops.secrets.gramps-web-postgresql-env.path;
    };
  };

  # Provision the two databases without switching the running Gramps backend.
  services.postgresql = {
    ensureDatabases = [ "gramps" "grampswebuser" ];
    ensureUsers = map (name: { inherit name; ensureDBOwnership = true; }) [ "gramps" "grampswebuser" ];
    authentication = lib.mkBefore ''
      host gramps        gramps        127.0.0.1/32 scram-sha-256
      host grampswebuser grampswebuser 127.0.0.1/32 scram-sha-256
    '';
  };

  systemd.services = lib.mkIf cfg.enable (lib.genAttrs
    [ "podman-gramps-web" "podman-gramps-web-worker" ]
    (_: {
      requires = [ "sops-install-secrets.service" ];
      after = [ "sops-install-secrets.service" ];
    }));

  # The SQL dump covers the databases, not tree metadata or media.
  services.restic.backups.pantry.paths = lib.mkIf cfg.enable (map
    (name: "/var/lib/gramps-web-postgresql/${name}")
    [ "trees" "media" "secret" ]);
}
