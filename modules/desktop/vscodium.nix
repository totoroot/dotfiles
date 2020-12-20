# modules/desktop/vscodium.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.vscodium;
in {
  options.modules.desktop.vscodium = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      vscodium
    ];
  };
}
