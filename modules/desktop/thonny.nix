# modules/desktop/thonny.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.thonny;
in {
  options.modules.desktop.thonny = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Python IDE for beginners
      thonny
    ];

    home.configFile = {
      "Thonny/configuration.ini".source = "${configDir}/thonny/configuration.ini";
    };
  };
}
