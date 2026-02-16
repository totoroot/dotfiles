{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.networking;
in
{
  config = mkMerge [
    {
      home.packages = with pkgs;
        [
          # Tool to measure IP bandwidth using UDP or TCP
          iperf3
          # Collection of common network programs (including telnet, hostname, ifconfig)
          inetutils
          # Tool for retrieving files using HTTP, HTTPS, and FTP
          wget
          # Network diagnostics tool
          mtr
          # Network discovery utility
          nmap
        ]
        ++ lib.optionals stdenv.isLinux [
          # Utility for controlling network drivers and hardware (Linux only)
          ethtool
        ];
    }
    # Open firewall ports for iperf when on NixOS
    (optionalAttrs (hasAttrByPath [ "networking" "firewall" ] options) {
      networking.firewall.allowedTCPPorts = [ 5201 ];
      networking.firewall.allowedUDPPorts = [ 5201 ];
    })
  ];
}
