{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.forgejo;
  domain = "xn--berwachungsbehr-mtb1g.de";
  hostName = "versions.${domain}";
in
{
  options.modules.services.forgejo = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # Keep the familiar git SSH identity while running Forgejo.
    users.users.git = {
      isSystemUser = true;
      useDefaultShell = true;
      home = "/var/lib/forgejo";
      group = "forgejo";
    };

    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;

      user = "git";
      group = "forgejo";

      database = {
        type = "postgres";
        name = "forgejo";
        user = "forgejo";
        createDatabase = false;
        host = "127.0.0.1";
        passwordFile = "/var/secrets/forgejo-db-password";
      };

      settings = {
        server = {
          DOMAIN = hostName;
          ROOT_URL = "https://${hostName}";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3001;
          DISABLE_SSH = false;
          SSH_PORT = 22;
        };
        session.COOKIE_SECURE = true;
        service.DISABLE_REGISTRATION = true;
        log.LEVEL = "Error";
      };
    };

    services.postgresql = mkIf config.modules.services.postgresql.enable {
      ensureDatabases = mkAfter [ "forgejo" ];
      ensureUsers = mkAfter [
        {
          name = "forgejo";
          ensureDBOwnership = true;
        }
      ];
    };

    user.extraGroups = [ "forgejo" ];
  };
}
