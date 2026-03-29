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
    # I prefer git@... ssh addresses over gitea@...
    users.users.git = {
      isSystemUser = true;
      useDefaultShell = true;
      home = "/var/lib/gitea";
      group = "gitea";
    };

    services.gitea = {
      enable = true;
      package = pkgs.forgejo;

      user = "git";
      database.user = "forgejo";
      database.type = "postgres";
      database.name = "forgejo";

      disableRegistration = true;

      # We're assuming SSL-only connectivity
      cookieSecure = true;
      # Only log what's important
      log.level = "Error";
      settings = {
        server = {
          DISABLE_ROUTER_LOG = true;
          DOMAIN = hostName;
          ROOT_URL = "https://${hostName}";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3001;
          SSH_DOMAIN = hostName;
          SSH_PORT = 22;
          START_SSH_SERVER = false;
        };
        service.DISABLE_REGISTRATION = true;
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

    user.extraGroups = [ "gitea" ];
  };
}
