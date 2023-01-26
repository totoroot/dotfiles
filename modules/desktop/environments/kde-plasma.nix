{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.environments.kde-plasma;
in {
  options.modules.desktop.environments.kde-plasma = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        # Display Manager for KDE Plasma
        displayManager = {
          sddm.enable = true;
          lightdm.enable = false;
        };
        # Enable KDE Plasma itself
        desktopManager = {
          plasma5 = {
            enable = true;
            # Exclude unnecessary KDE packages
            excludePackages = with pkgs.libsForQt5; [
              elisa
              gwenview
              okular
              oxygen
              khelpcenter
              konsole
            ];
          };
        };
      };
    };
  };
}
