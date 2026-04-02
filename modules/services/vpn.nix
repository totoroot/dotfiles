# modules/services/vpn.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.vpn;
in {
  options.modules.services.vpn = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mullvad-vpn
    ];

    networking.wireguard.enable = true;
    networking.iproute2.enable = true;
    networking.firewall.checkReversePath = "loose";
    services.mullvad-vpn.enable = true;

    # Delay Mullvad startup until network and tailscale autoconnect settled.
    systemd.services.mullvad-daemon = {
      after = [
        "network-online.target"
        "tailscaled.service"
        "tailscale-autoconnect.service"
      ];
      wants = [
        "network-online.target"
        "tailscaled.service"
        "tailscale-autoconnect.service"
      ];
      serviceConfig.ExecStartPre = [ "${pkgs.coreutils}/bin/sleep 8" ];
    };
  };
}
