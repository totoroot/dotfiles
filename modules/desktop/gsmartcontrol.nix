{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.gsmartcontrol;
in {
  options.modules.desktop.gsmartcontrol = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gsmartcontrol
    ];
  };
}
