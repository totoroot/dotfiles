{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.environments.kde-plasma;
in {
  options.modules.desktop.environments.kde-plasma = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    ];

    services = {
      xserver = {
        enable = true;
        displayManager = {
          sddm.enable = true;
        };
        desktopManager = {
          plasma5 = {
            enable = true;
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

    programs.dconf.enable = true;
  };
}
