{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.nix.atticCache;
in
{
  options.modules.nix.atticCache = {
    enableServer = mkEnableOption "Attic binary cache server";
    enableClient = mkEnableOption "Attic binary cache client";

    host = mkOption {
      type = types.str;
      default = "purple-ts";
      description = "Hostname (or Tailscale name) of the Attic server.";
    };

    clientHost = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Hostname used by the Attic client to reach the server.";
    };

    cacheName = mkOption {
      type = types.str;
      default = "purple-cache";
      description = "Attic cache name used in the binary cache endpoint.";
    };

    port = mkOption {
      type = types.port;
      default = 5129;
      description = "Attic server port.";
    };

    publicKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Attic cache public key (e.g. cache-name:BASE64).";
    };

    environmentFile = mkOption {
      type = types.str;
      default = "/etc/atticd.env";
      description = "Environment file containing ATTIC_SERVER_TOKEN_* secrets.";
    };

    clientTokenEnvVar = mkOption {
      type = types.str;
      default = "ATTIC_CLIENT_TOKEN";
      description = "Environment variable name holding the Attic client token.";
    };

    storagePath = mkOption {
      type = types.str;
      default = "/var/lib/atticd/storage";
      description = "Local storage path for Attic NARs/chunks.";
    };

    databaseUrl = mkOption {
      type = types.str;
      default = "sqlite:///var/lib/atticd/atticd.db?mode=rwc";
      description = "Database URL for Attic.";
    };

    enableWatcher = mkOption {
      type = types.bool;
      default = false;
      description = "Enable attic watch-store to auto-upload to the cache.";
    };
  };

  config = mkMerge [
    (mkIf cfg.enableServer {
      services.atticd = {
        enable = true;
        environmentFile = cfg.environmentFile;
        settings = {
          listen = "[::]:${toString cfg.port}";
          database = { url = cfg.databaseUrl; };
          storage = {
            type = "local";
            path = cfg.storagePath;
          };
        };
      };

      systemd.services.attic-watch-store = mkIf cfg.enableWatcher {
        description = "Attic watch-store uploader";
        after = [ "atticd.service" "attic-client-login.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Restart = "always";
          RestartSec = 5;
        };
        script = ''
          exec ${pkgs.attic-client}/bin/attic watch-store ${cfg.cacheName}
        '';
      };
    })

    (mkIf cfg.enableClient {
      systemd.services.attic-client-login = {
        description = "Login Attic client";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          EnvironmentFile = cfg.environmentFile;
        };
        script = ''
          set -euo pipefail
          token_var="${cfg.clientTokenEnvVar}"
          token_value="$(printenv "$token_var" || true)"
          if [ -z "$token_value" ]; then
            echo "Missing ${cfg.clientTokenEnvVar} in ${cfg.environmentFile}" >&2
            exit 1
          fi
          export HOME=/root
          export XDG_CONFIG_HOME=/root/.config
          install -d /root/.config/attic
          if [ ! -f /root/.config/attic/config.toml ]; then
            printf '%s\n' "$token_value" | ${pkgs.attic-client}/bin/attic login "http://${cfg.clientHost}:${toString cfg.port}"
          fi
        '';
      };

      nix.settings = mkMerge [
        {
          connect-timeout = 1;
          download-attempts = 1;
          substituters = lib.mkForce [
            "http://${cfg.host}:${toString cfg.port}/${cfg.cacheName}"
            "https://cache.nixos.org/"
            "https://nix-community.cachix.org"
          ];
        }
        (mkIf (cfg.publicKey != null) {
          trusted-public-keys = [ cfg.publicKey ];
        })
      ];

      environment.systemPackages = [ pkgs.attic-client ];
    })
  ];
}
