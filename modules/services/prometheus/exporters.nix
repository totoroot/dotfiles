# modules/services/prometheus/exporters.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.prometheus.exporters;
  fritzbox-local-ip = "192.168.0.1";
in
{
  options.modules.services.prometheus.exporters = {
    # Only the node exporter should be enabled by default
    node.enable = mkBoolOpt true;
    systemd.enable = mkBoolOpt false;
    statsd.enable = mkBoolOpt false;
    smartctl.enable = mkBoolOpt false;
    blackbox.enable = mkBoolOpt false;
    nginx.enable = mkBoolOpt false;
    nginxlog.enable = mkBoolOpt false;
    fail2ban.enable = mkBoolOpt false;
    adguard.enable = mkBoolOpt false;
    fritzbox.enable = mkBoolOpt false;
    speedtest.enable = mkBoolOpt false;
    postgres.enable = mkBoolOpt false;
    tailscale.enable = mkBoolOpt false;
    wireguard.enable = mkBoolOpt false;
    process.enable = mkBoolOpt false;
    nextcloud.enable = mkBoolOpt false;
  };

  config = {
    services.prometheus.exporters = {
      node = mkIf cfg.node.enable {
        enable = true;
        port = 9100;
        # extraFlags = [ "--collector.textfile.directory=/etc/nix" ];
      };

      systemd = mkIf cfg.systemd.enable {
        enable = true;
        port = 9558;
      };

      statsd = mkIf cfg.statsd.enable {
        enable = true;
        port = 9102;
      };

      smartctl = mkIf cfg.smartctl.enable {
        enable = true;
        port = 9633;
      };

      blackbox = mkIf cfg.blackbox.enable {
        enable = true;
        port = 9115;
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

      postgres = mkIf cfg.postgres.enable {
        enable = true;
        port = 9187;
        dataSourceName = "postgresql:///postgres?host=/run/postgresql";
      };

      tailscale = mkIf cfg.tailscale.enable {
        enable = true;
        port = 9101;
      };

      wireguard = mkIf cfg.wireguard.enable {
        enable = true;
        port = 9586;
      };

      process = mkIf cfg.process.enable {
        enable = true;
        port = 9256;
      };

      nextcloud = mkIf cfg.nextcloud.enable {
        enable = true;
        port = 9205;
      };
    };

    systemd.services = {
      "fail2ban-exporter" = mkIf cfg.fail2ban.enable {
        enable = true;
        description = "Fail2ban metric exporter for Prometheus";
        documentation = [ "https://gitlab.com/hectorjsmith/fail2ban-prometheus-exporter/-/blob/main/README.md" ];
        wantedBy = [ "multi-user.target" ];
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
        serviceConfig = {
          ExecStart = "/sbin/adguard-exporter -adguard_hostname 127.0.0.1 -adguard_port 3300  -log_limit 10000";
          Restart = "on-failure";
          RestartSec = 5;
          NoNewPrivileges = true;
          User = "root";
          Group = "root";
        };
      };
      "fritzbox-exporter" = mkIf cfg.fritzbox.enable {
        enable = true;
        description = "FRITZ!Box metric exporter for Prometheus";
        documentation = [ "https://github.com/sberk42/fritzbox_exporter/blob/master/README.md" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          # See this example
          # https://github.com/sberk42/fritzbox_exporter/blob/master/systemd/fritzbox_exporter.service
          ExecStart = "/sbin/fritzbox-exporter -gateway-url http://${fritzbox-local-ip}:49000 -metrics-file /var/lib/fritzbox-exporter/metrics.json -lua-metrics-file /var/lib/fritzbox-exporter/metrics-lua.json -listen-address 127.0.0.1:9134";
          EnvironmentFile = "/var/secrets/fritzbox-exporter.env";
          Restart = "on-failure";
          RestartSec = 5;
          NoNewPrivileges = true;
          User = "root";
          Group = "root";
        };
      };
      "speedtest-exporter" = mkIf cfg.speedtest.enable {
        enable = true;
        description = "Speedtest Prometheus Exporter exposing results from speedtest.net";
        documentation = [ "https://github.com/danopstech/speedtest_exporter/blob/main/README.md" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "/sbin/speedtest-exporter -port 9862"; # -server_id 15152";
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
      ++ lib.optional cfg.smartctl.enable config.services.prometheus.exporters.smartctl.port
      ++ lib.optional cfg.blackbox.enable config.services.prometheus.exporters.blackbox.port
      ++ lib.optional cfg.nginx.enable config.services.prometheus.exporters.nginx.port
      ++ lib.optional cfg.nginxlog.enable config.services.prometheus.exporters.nginxlog.port
      ++ lib.optional cfg.fail2ban.enable 9191
      ++ lib.optional cfg.adguard.enable 9617
      ++ lib.optional cfg.fritzbox.enable 9134
      ++ lib.optional cfg.speedtest.enable 9862
      ++ lib.optional cfg.postgres.enable config.services.prometheus.exporters.postgres.port
      ++ lib.optional cfg.tailscale.enable config.services.prometheus.exporters.tailscale.port
      ++ lib.optional cfg.wireguard.enable config.services.prometheus.exporters.wireguard.port
      ++ lib.optional cfg.process.enable config.services.prometheus.exporters.process.port
      ++ lib.optional cfg.nextcloud.enable config.services.prometheus.exporters.nextcloud.port;
  };
}
