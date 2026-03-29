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
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;

      # Keep defaults for service user/group from the Forgejo module.
      database = {
        type = "postgres";
        name = "forgejo";
        user = "forgejo";
        socket = "/run/postgresql";
        createDatabase = false;
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
