# modules/browser/lynx.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.browsers.lynx;
in {
  options.modules.desktop.browsers.lynx = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      lynx
    ];
  };
}
