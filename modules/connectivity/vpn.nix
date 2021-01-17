# modules/connectivity/vpn.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.connectivity.vpn;
in {
  options.modules.connectivity.vpn = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mullvad-vpn
    ];

    networking.wireguard.enable = true;
    networking.iproute2.enable = true;
    services.mullvad-vpn.enable = true;
  };
}
