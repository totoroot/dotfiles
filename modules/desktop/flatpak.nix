# modules/desktop/flatpak.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.flatpak;
in {
  options.modules.desktop.flatpak = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      flatpak
    ];

    # Enable flatpak to install packages from flathub
    services.flatpak.enable = true;

    # Enable portal for xdg files for packages installed with flatpak
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Add flathub repo for all users
    systemd.services.configure-flathub-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
