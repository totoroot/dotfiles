{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.calibre;
in {
  options.modules.desktop.calibre = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      calibre
    ];

    home.configFile = {
      "calibre/store/search.json".source = "${configDir}/calibre/search.json";
      "calibre/global.py.json".source = "${configDir}/calibre/global.py.json";
    };
  };
}
