{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.ghostwriter;
in {
  options.modules.desktop.apps.ghostwriter = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ghostwriter
    ];
  };
}
