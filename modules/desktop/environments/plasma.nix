{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.environments.plasma;
in {
  options.modules.desktop.environments.plasma = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      # Display Manager for KDE Plasma
      displayManager.sddm = {
        # Make it rewritable in case Plasma should be installed
        # but other display manager should be used
        enable = mkDefault true;
        # Use Wayland Session by default
        wayland.enable = mkDefault true;
      };
      xserver = {
        enable = true;
      };
      # Enable KDE Plasma itself
      desktopManager.plasma6 = {
        enable = true;
        enableQt5Integration = true;
      };
    };

    # Enable KDE connect for all Plasma desktops
    programs.kdeconnect.enable = true;

    # Exclude unnecessary KDE packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      gwenview
      okular
      oxygen
      khelpcenter
      konsole
    ];

    # Install a calculator
    environment.systemPackages = with pkgs.kdePackages; [
      kcalc
    ];
  };
}
