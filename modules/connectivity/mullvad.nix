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
      mullvad-vpn
    ];

    services.mullvad-vpn.enable = true;

  	# Workaround for https://github.com/NixOS/nixpkgs/issues/91923
  	# networking.iproute2.enable = true;
  };
}
