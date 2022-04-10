# modules/dev/lua.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.dev.lua;
in {
  options.modules.dev.lua = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Powerful, fast, lightweight, embeddable scripting language
      lua
    ];
  };
}
