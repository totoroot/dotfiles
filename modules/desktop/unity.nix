{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.unity;
in {
  options.modules.desktop.unity = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Official Unity3D app to download and manage Unity Projects and installations
      unityhub
    ];
  };
}
