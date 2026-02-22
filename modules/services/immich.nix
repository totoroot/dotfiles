{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.immich;
  domain = "foto.xn--berwachungsbehr-mtb1g.de";
  port = 2283;
  storagePath = "/var/lib/immich";
in
{
  options.modules.services.immich = {
    enable = mkBoolOpt false;
    openFirewall = mkBoolOpt true;
    storagePath = mkOpt types.str storagePath;
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      port = port;
      mediaLocation = cfg.storagePath;
      redis = {
        enable = true;
        host = "127.0.0.1";
        port = 6379;
      };
      # TODO: add reverse proxy config and external domain when needed
      # settings.server.externalDomain = "https://${domain}";
    };

    services.redis.servers.immich = {
      enable = true;
      port = 6379;
    };

    services.postgresql = mkIf config.modules.services.postgresql.enable {
      ensureDatabases = mkAfter [ "immich" ];
      ensureUsers = mkAfter [{
        name = "immich";
        ensureDBOwnership = true;
      }];
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      mkIf cfg.openFirewall [ port ];
  };
}
