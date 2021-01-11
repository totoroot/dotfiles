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
    user.packages = with pkgs; [
      unstable.mullvad-vpn
    ];

    services.mullvad-vpn.enable = true;

    networking.iproute2.enable = true;
  };
}
