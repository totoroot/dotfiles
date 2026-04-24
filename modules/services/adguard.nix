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
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.tailscale0 = {
      allowedUDPPorts = [ adguardDNSPort ];
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
      port = adguardHTTPPort;
    };

    # For troubleshooting DNS
    environment.systemPackages = with pkgs; [
      # Collection of common network programs (e.g. ftp, ping, traceroute, hostname, ifconfig)
      inetutils
      # DNS tools (e.g. nslookup, dig)
      dnsutils
    ];
  };
}
