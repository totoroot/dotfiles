{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.environments.xfce;
in {
  options.modules.desktop.environments.xfce = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        # Display Manager for XFCE
        displayManager = {
          sddm.enable = true;
          lightdm.enable = false;
        };
        # Enable XFCE and its modules itself
        desktopManager = {
          xfce = {
            enable = true;
            enableScreensaver = true;
            enableXfwm = true;
          };
        };
      };
    };
  };
}
