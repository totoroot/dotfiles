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

## Exporter notes

- `node`: General host metrics (CPU, memory, disk, etc.)
- `systemd`: Systemd unit metrics
- `statsd`: StatsD relay metrics
- `smartctl`: Disk SMART metrics
- `nginx`: NGINX stub status metrics
- `nginxlog`: NGINX access log metrics
- `fail2ban`: Fail2ban ban metrics (custom exporter service)
- `ntfy`: Ntfy metrics (custom exporter/service on jam)
- `adguard`: AdGuard Home metrics (custom exporter service)
- `fritzbox`: Fritz!Box metrics (custom exporter service)
- `speedtest`: Speedtest exporter (custom exporter service)
- `homeAssistant`: Home Assistant `/api/prometheus` endpoint
- `blackbox`: Blackbox exporter itself (probe gateway)
- `tailscale`: Tailscale exporter
- `wireguard`: WireGuard exporter
- `process`: Process exporter (per-process stats)
- `nextcloud`: Nextcloud exporter. Generate and set the serverinfo token on the Nextcloud host:
  ```
  TOKEN=$(openssl rand -hex 32)
  sudo -u nextcloud /run/current-system/sw/bin/nextcloud-occ \
      config:app:set serverinfo token --value "$TOKEN"
  ```
- `immich`: Immich exporter (custom container)
