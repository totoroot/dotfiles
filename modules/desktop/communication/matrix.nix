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
      element-desktop
      unstable.fractal
      unstable.weechat
      unstable.weechatScripts.weechat-matrix
    ];
  };
}
