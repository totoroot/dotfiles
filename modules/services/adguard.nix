{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.adguard;
  adguardHTTPPort = 6060;
  jamTailnetIP = "100.64.0.1";
  lanCIDR = "10.0.0.0/24";
  # AdGuard Home uses port 53 for DNS by default
  adguardDNSPort = 53;
in
{
  options.modules.services.adguard = {
    enable = mkBoolOpt false;
    openFirewall = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.tailscale0 = {
      allowedUDPPorts = [ adguardDNSPort ];
      allowedTCPPorts = mkIf cfg.openFirewall [ adguardHTTPPort ];
    };

    # Web UI is reachable from LAN and from jam's reverse proxy, where the
    # public vhost is protected by Authelia. DNS is reachable from LAN.
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --source ${jamTailnetIP} --dport ${toString adguardHTTPPort} -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --source ${lanCIDR} --dport ${toString adguardHTTPPort} -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --source ${lanCIDR} --dport ${toString adguardDNSPort} -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source ${lanCIDR} --dport ${toString adguardDNSPort} -j nixos-fw-accept
    '';

    services.adguardhome = {
      enable = true;
      mutableSettings = true;
      host = "0.0.0.0";
      port = adguardHTTPPort;

      # Configure upstream DNS servers and other settings
      settings = {
        # Use the current schema version from the package
        # schema_version is automatically set by the package

        # DNS configuration
        dns = {
          # Use multiple upstream DNS providers for redundancy
          upstream_dns = [
            "https://dns.quad9.net/dns-query"
            "https://cloudflare-dns.com/dns-query"
            "https://dns.google/dns-query"
            "tls://1.1.1.1"
            "tls://1.0.0.1"
          ];
          # Enable DNS caching
          caching = true;
          # Cache size and TTL
          cache_size = 10000000; # 10MB cache
          cache_ttl_min = 0;
          cache_ttl_max = 86400;
          # Enable DNSSEC
          dnssec = true;
          # Enable EDNS Client Subnet
          edns_cs_enabled = false;
        };

        # Query logging for debugging
        query_log = {
          enabled = true;
          file_enabled = true;
          interval = 24; # hours
          # Log anonymized client IP addresses
          anonymize_client_ip = true;
        };

        # Statistics configuration
        stats = {
          enabled = true;
          interval = 1; # hours
        };

        # Filtering configuration
        filtering = {
          enabled = true;
          # Use default filter lists
          protection_enabled = true;
          # Block IPv6 addresses in filters
          blocking_ipv6 = true;
          # Number of filtering rules to load at once
          filters_update_interval = 24;
        };

        # Clients configuration
        clients = {
          # Persistent clients configuration
          persistent = [
            {
              name = "LAN Clients";
              ids = [ "${lanCIDR}" ];
            }
          ];
        };

        # Logging configuration
        log = {
          file = "";
          max_backups = 0;
          max_size = 100;
          max_age = 3;
          compress = false;
          local_time = false;
          verbose = false;
        };
      };
    };
  };
}
