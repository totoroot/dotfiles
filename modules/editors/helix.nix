{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.helix;
in {
  options.modules.editors.helix = {
    enable = mkBoolOpt false;
    desktop.enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Post-modern modal text editor
      helix
    ];

    environment.shellAliases = {
      helix = "hx";
    };

    home.configFile = {
      "helix/config.toml".source = "${configDir}/helix/config.toml";
    };
  };
}
