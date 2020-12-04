{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.term.kitty;
in {
  options.modules.desktop.term.kitty = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      kitty
    ];
    home.configFile = {
      "kitty/kitty.conf".source = "${configDir}/kitty/kitty.conf";
    };
  };
}
