{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.environments.lxqt;
in {
  options.modules.desktop.environments.lxqt = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        # Display Manager for LXQt
        displayManager = {
          sddm.enable = true;
          lightdm.enable = false;
        };
        # Enable LXQt itself
        desktopManager.lxqt.enable = true;
      };
      connman.enable = true;
    };
    # Exclude unnecessary LXQt packages
    environment.lxqt.excludePackages = with pkgs.lxqt; [
    ];
    xdg.portal.lxqt.enable = true;
    programs.nm-applet.enable = true;
  };
}
