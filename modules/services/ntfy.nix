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
        auth-file = "/var/lib/ntfy/user.db";
        # cache-file = "/var/cache/ntfy/cache.db";
        attachment-cache-dir = "/var/cache/ntfy/attachments";
        auth-default-access = "deny-all";
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
