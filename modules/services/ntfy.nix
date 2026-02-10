{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.ntfy;
  domain = "xn--berwachungsbehr-mtb1g.de";
  ntfyPort = 6780;
  ntfyMetricsPort = 9095;
  ntfyHost = "benachrichtigungs.${domain}";
in
{
  options.modules.services.ntfy = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      group = "ntfy";
      user = "ntfy";
      settings = {
        base-url = "https://${ntfyHost}";
        listen-http = ":${toString ntfyPort}";
        behind-proxy = true;
        auth-file = "/var/lib/ntfy-sh/user.db";
        auth-default-access = "deny-all";
        auth-users = [
          # "fp5:$2a$10$YLiO8U21sX1uhZamTLJXHuxgVC0Z/GKISibrKCLohPgtG7yIxSk4C:user"
          # "uptime-kuma:$2a$10$NKbrNb7HPMjtQXWJ0f1pouw03LDLT/WzlO9VAv44x84bRCkh19h6m:user"
        ];
        auth-access = [
          # Needed to get UnifiedPush to work if deny-all default access
          "*:up*:rw"
          "*:service-status:rw"
          "*:announcements:ro"
        ];
        # cache-file = "/var/cache/ntfy/cache.db";
        # attachment-cache-dir = "/var/cache/ntfy/attachments";
        upstream-base-url = "https://ntfy.sh";
        # Set to "disable" to disable web UI
        # See https://github.com/binwiederhier/ntfy/issues/459
        web-root = "app";
        # Enable metrics endpoint for Prometheus
        enable-metrics = true;
        metrics-listen-http = ":${toString ntfyMetricsPort}";
      };
    };

    users = {
      groups."ntfy" = { };
      users."ntfy" = {
        name = "ntfy";
        group = "ntfy";
        isSystemUser = true;
      };
    };

    user.extraGroups = [ "ntfy" ];

    environment.systemPackages = [ config.services.ntfy-sh.package ];

    networking.firewall.allowedTCPPorts = [ ntfyPort ];
  };
}
