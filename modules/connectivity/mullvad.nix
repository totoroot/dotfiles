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

    # autostart still does not work -> workaround in bspwmrc
    # xdg.configFile."autostart/mullvad-vpn.desktop".source = "${mullvad-vpn}/share/applications/mullvad-vpn.desktop";
  };
}
