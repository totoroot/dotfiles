# modules/browser/tor.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.browsers.tor;
in {
  options.modules.desktop.browsers.tor = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      tor-browser-bundle-bin
    ];
  };
}
