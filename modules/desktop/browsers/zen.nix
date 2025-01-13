# modules/desktop/browsers/zen.nix

{ options, inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.browsers.zen;
in {
  options.modules.desktop.browsers.zen = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      inputs.zen-browser.packages.${system}.default
    ];
  };
}
