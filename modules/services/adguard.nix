{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.adguard;
  adguardHTTPPort = 3300;
  # AdGuard Home uses port 53 for DNS by default
  adguardDNSPort = 53;
in
{
  options.modules.services.adguard = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [ adguardHTTPPort ];
      allowedUDPPorts = [ adguardDNSPort ];
    };

    services.adguardhome = {
      enable = true;
      mutableSettings = true;
      settings = {
        http = {
          address = "0.0.0.0:${toString adguardHTTPPort}";
        };
      };
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
