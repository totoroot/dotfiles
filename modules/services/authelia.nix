{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.authelia;
  domain = "xn--berwachungsbehr-mtb1g.de";
in
{
  options.modules.services.authelia = {
    enable = mkBoolOpt false;

    hostName = mkOpt types.str "auth.${domain}";

    legacyHostNames = mkOpt (types.listOf types.str) [ "auth.${domain}" ];

    port = mkOpt types.port 9091;

    cookieDomain = mkOpt types.str domain;

    usersDatabaseFile = mkOpt types.str "/var/secrets/authelia/users_database.yml";

    jwtSecretFile = mkOpt types.str "/var/secrets/authelia/jwt_secret";

    storageEncryptionKeyFile = mkOpt types.str "/var/secrets/authelia/storage_encryption_key";

    sessionSecretFile = mkOpt types.str "/var/secrets/authelia/session_secret";
  };

  config = mkIf cfg.enable {
    # Foundation services for the auth stack.
    services.redis.servers.authelia = {
      enable = true;
      port = 6379;
      bind = "127.0.0.1";
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "authelia" ];
      ensureUsers = [
        {
          name = "authelia";
          ensureDBOwnership = true;
        }
      ];
    };

    services.authelia.instances.main = {
      enable = true;
      user = "authelia";
      group = "authelia";
      secrets = {
        jwtSecretFile = cfg.jwtSecretFile;
        storageEncryptionKeyFile = cfg.storageEncryptionKeyFile;
        sessionSecretFile = cfg.sessionSecretFile;
      };
      settings = {
        theme = "dark";
        default_2fa_method = "totp";
        log.level = "info";
        server.address = "tcp://127.0.0.1:${toString cfg.port}/";

        authentication_backend.file.path = cfg.usersDatabaseFile;

        access_control.default_policy = "one_factor";

        session = {
          cookies = [
            {
              name = "authelia_session";
              domain = cfg.cookieDomain;
              authelia_url = "https://${cfg.hostName}";
            }
          ];
          redis = {
            host = "127.0.0.1";
            port = 6379;
          };
        };

        storage.postgres = {
          address = "unix:///run/postgresql";
          database = "authelia";
          username = "authelia";
        };

        notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";
      };
    };

    users.groups.authelia = { };
    users.users.authelia = {
      isSystemUser = true;
      group = "authelia";
    };

    services.nginx.virtualHosts = mkIf config.modules.services.nginx.enable (
      {
        "${cfg.hostName}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
          };
        };
      }
      // builtins.listToAttrs (
        map (host: {
          name = host;
          value = {
            enableACME = true;
            forceSSL = true;
            globalRedirect = cfg.hostName;
          };
        })
        (filter (h: h != cfg.hostName) cfg.legacyHostNames)
      )
    );

    environment.systemPackages = [ config.services.authelia.instances.main.package ];
  };
}
