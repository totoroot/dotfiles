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
  };
}
