# modules/services/prometheus/exporters.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.prometheus.exporters;
in {
  options.modules.services.prometheus.exporters = {
    # Only the node exporter should be enabled by default
    node.enable = mkBoolOpt true;
    systemd.enable = mkBoolOpt false;
    statsd.enable = mkBoolOpt false;
    blackbox.enable = mkBoolOpt false;
    nginx.enable = mkBoolOpt false;
    nginxlog.enable = mkBoolOpt false;
    fail2ban.enable = mkBoolOpt false;
    adguard.enable = mkBoolOpt false;
  };

  config = {
    services.prometheus.exporters = {
      node = mkIf cfg.node.enable {
        enable = true;
        port = 9100;
        openFirewall = false;
        # extraFlags = [ "--collector.textfile.directory=/etc/nix" ];
      };

      systemd = mkIf cfg.systemd.enable {
        enable = true;
        port = 9558;
        openFirewall = false;
      };

      statsd = mkIf cfg.statsd.enable {
        enable = true;
        port = 9102;
        openFirewall = false;
      };

      blackbox = mkIf cfg.blackbox.enable {
        enable = true;
        port = 9115;
        openFirewall = false;
        configFile = pkgs.writeTextFile {
          name = "blackbox-exporter-config";
          text = ''
            modules:
              http_2xx:
                prober: http
                timeout: 5s
                http:
                  valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
                  valid_status_codes: []  # Defaults to 2xx
                  method: GET
                  no_follow_redirects: false
                  fail_if_ssl: false
                  fail_if_not_ssl: false
                  tls_config:
                    insecure_skip_verify: false
                  preferred_ip_protocol: "ip4" # defaults to "ip6"
                  ip_protocol_fallback: true  # fallback to "ip6"
          '';
        };
      };

      nginx = mkIf cfg.nginx.enable {
        enable = true;
        port = 9113;
        openFirewall = false;
      };

      nginxlog = mkIf cfg.nginxlog.enable {
        enable = true;
        port = 9117;
        openFirewall = false;
      };
    };

    systemd.services = {
      "fail2ban-exporter" = mkIf cfg.fail2ban.enable {
        enable = true;
        description = "Fail2ban metric exporter for Prometheus";
        documentation = [ "https://gitlab.com/hectorjsmith/fail2ban-prometheus-exporter/-/blob/main/README.md" ];
        wantedBy = [ "multi-user.target" ];
        requires = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          # See this example
          # https://gitlab.com/hectorjsmith/fail2ban-prometheus-exporter/-/blob/main/_examples/systemd/fail2ban_exporter.service?ref_type=heads
          ExecStart = "/sbin/fail2ban-exporter";
          Restart = "on-failure";
          RestartSec = 5;
          NoNewPrivileges = true;
          User = "root";
          Group = "root";
        };
      };
      "adguard-exporter" = mkIf cfg.adguard.enable {
        enable = true;
        description = "AdGuard metric exporter for Prometheus";
        documentation = [ "https://github.com/totoroot/adguard-exporter/blob/master/README.md" ];
        wantedBy = [ "multi-user.target" ];
        requires = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          ExecStart = "/sbin/adguard-exporter";
          Restart = "on-failure";
          RestartSec = 5;
          NoNewPrivileges = true;
          User = "root";
          Group = "root";
        };
      };
    };

    # Open firewall ports on the tailscale0 interface
    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      lib.optional cfg.node.enable config.services.prometheus.exporters.node.port
      ++ lib.optional cfg.systemd.enable config.services.prometheus.exporters.systemd.port
      ++ lib.optional cfg.statsd.enable config.services.prometheus.exporters.statsd.port
      ++ lib.optional cfg.blackbox.enable config.services.prometheus.exporters.blackbox.port
      ++ lib.optional cfg.nginx.enable config.services.prometheus.exporters.nginx.port
      ++ lib.optional cfg.nginxlog.enable config.services.prometheus.exporters.nginxlog.port
      ++ lib.optional cfg.fail2ban.enable 9191
      ++ lib.optional cfg.adguard.enable 9617;
  };
}
