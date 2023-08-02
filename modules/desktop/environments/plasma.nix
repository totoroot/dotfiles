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
      xserver = {
        enable = true;
        # Display Manager for KDE Plasma
        displayManager = {
          # Make it rewritable in case Plasma should be installed
          # but other display manager should be used
          sddm.enable = mkDefault true;
        };
        # Enable KDE Plasma itself
        desktopManager.plasma5.enable = true;
      };
    };

    # Enable KDE connect for all Plasma desktops
    programs.kdeconnect.enable = true;

    # Exclude unnecessary KDE packages
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
      elisa
      gwenview
      okular
      oxygen
      khelpcenter
      konsole
    ];

    # Install a calculator
    environment.systemPackages = with pkgs.libsForQt5; [
      kcalc
    ];
  };
}
