{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.ghostwriter;
in {
  options.modules.desktop.ghostwriter = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ghostwriter
    ];
  };
}
