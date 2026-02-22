# Prometheus Module Notes

This module defines a Prometheus server plus exporter helpers in:

- `default.nix` (server config + scrape targets)
- `exporters.nix` (exporter enable flags + firewall openings)

## Per-job scrape hosts

By default, each scrape job targets **all** hosts listed in `hosts/ips.nix`.
You can limit targets per job with:

```nix
modules.services.prometheus.scrapeHosts = {
  node = [ "jam" "purple" ];
  nginx = [ "jam" ];
  ntfy = [ "jam" ];
  # Empty or unset => all hosts from hosts/ips.nix
};
```

Supported keys: `node`, `blackbox`, `systemd`, `statsd`, `smartctl`, `nginx`,
`nginxlog`, `fail2ban`, `ntfy`, `adguard`, `fritzbox`, `speedtest`,
`homeAssistant`.
