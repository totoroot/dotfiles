# modules/desktop/communication/matrix.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.communication.matrix;
in {
  options.modules.desktop.communication.matrix = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # A feature-rich client for Matrix.org
      element-desktop
      # Desktop client for the Matrix protocol
      nheko
    ];
  };
}
