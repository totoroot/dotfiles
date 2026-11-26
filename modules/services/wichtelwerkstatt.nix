{ config, lib, pkgs, ... }:
let
  cfg = config.modules.services.wichtelwerkstatt;
  name = "wichtelwerkstatt";
  runtime = pkgs.python3.withPackages (p: [ p.flask p.gunicorn p.psycopg ]);
  state = "/var/lib/${name}";
  initializeKey = pkgs.writeShellScript "wichtelwerkstatt-key" ''
    set -eu
    key=${state}/signing-key
    if [ ! -e "$key" ]; then
      tmp=$(${pkgs.coreutils}/bin/mktemp "$key.XXXXXX")
      trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT
      ${runtime}/bin/python3 -c 'import secrets; print(secrets.token_hex(32))' > "$tmp"
      ${pkgs.coreutils}/bin/mv -T "$tmp" "$key"
    fi
    test -s "$key"
  '';
  environment = {
    WICHTEL_BASE_URL = "https://${cfg.hostName}";
    WICHTEL_DATABASE_URL = "postgresql:///${name}?host=/run/postgresql";
    WICHTEL_SECRET_FILE = "${state}/signing-key";
    WICHTEL_TRUST_PROXY = "1";
    WICHTEL_MAIL = if cfg.sendMail then "enabled" else "disabled";
    PYTHONDONTWRITEBYTECODE = "1";
  };
  serviceDefaults = {
    inherit environment;
    unitConfig.ConditionPathExists = "${cfg.webRoot}/.app/backend/app.py";
    after = [ "postgresql.service" "postgresql-setup.service" ];
    requires = [ "postgresql.service" "postgresql-setup.service" ];
    serviceConfig = {
      User = name;
      Group = name;
      StateDirectory = name;
      StateDirectoryMode = "0700";
      WorkingDirectory = "${cfg.webRoot}/.app";
      UMask = "0077";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
    };
  };
in
{
  options.modules.services.wichtelwerkstatt = {
    enable = lib.mkEnableOption "the Wichtelwerkstatt exchange service and vhost";
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "wichteln.thym.it";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8394;
    };
    webRoot = lib.mkOption {
      type = lib.types.str;
      default = "/var/www/wichteln.thym.it";
      description = "GitLab CI rsync destination containing Hugo and the private .app payload.";
    };
    sendMail = lib.mkEnableOption "delivery through local Postfix";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.postgresql.enable;
        message = "Wichtelwerkstatt requires local PostgreSQL.";
      }
    ];

    users.groups.${name} = { };
    users.users.${name} = { isSystemUser = true; group = name; };
    services.postgresql = {
      ensureDatabases = [ name ];
      ensureUsers = [{ inherit name; ensureDBOwnership = true; }];
    };
    systemd.tmpfiles.rules = [
      "d ${state} 0700 ${name} ${name} -"
    ];

    systemd.services.wichtelwerkstatt = lib.recursiveUpdate serviceDefaults {
      description = "Wichtelwerkstatt web application";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStartPre = initializeKey;
        ExecStart = "${runtime}/bin/gunicorn --bind 127.0.0.1:${toString cfg.port} --workers 2 backend.app:create_app()";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
    systemd.services.wichtelwerkstatt-maintenance = lib.recursiveUpdate serviceDefaults {
      description = "Purge expired Wichtelwerkstatt data and process the outbox";
      after = serviceDefaults.after ++ [ "wichtelwerkstatt.service" "postfix.service" ];
      requires = serviceDefaults.requires ++ [ "wichtelwerkstatt.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${runtime}/bin/flask --app backend.app maintenance";
        TimeoutStartSec = "30min";
      };
    };
    systemd.timers.wichtelwerkstatt-maintenance = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnBootSec = "1min"; OnUnitInactiveSec = "1min"; };
    };
    systemd.paths.wichtelwerkstatt-deploy = {
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = "${cfg.webRoot}/.revision";
    };
    systemd.services.wichtelwerkstatt-deploy = {
      description = "Restart Wichtelwerkstatt after a successful CI sync";
      unitConfig.ConditionPathExists = "${cfg.webRoot}/.app/backend/app.py";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl restart wichtelwerkstatt.service";
      };
    };

    services.nginx.virtualHosts.${cfg.hostName} = {
      enableACME = true;
      forceSSL = true;
      root = cfg.webRoot;
      extraConfig = ''
        error_page 404 /404.html;
      '';
      locations = {
        "/".extraConfig = "try_files $uri $uri/ =404;";
        "= /.app".extraConfig = "return 404;";
        "^~ /.app/".extraConfig = "return 404;";
        "= /404.html".extraConfig = "internal;";
        "^~ /runde/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          recommendedProxySettings = false;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_cache off;
            access_log off;
            error_log /dev/null;
          '';
        };
      };
    };
  };
}
