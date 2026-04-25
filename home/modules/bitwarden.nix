{ config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.bitwarden;
in
{
  options.modules.home.bitwarden = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
    ];
  };
}
