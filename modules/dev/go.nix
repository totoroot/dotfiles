# modules/dev/go.nix

{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let cfg = config.modules.dev.go;
in {
  options.modules.dev.go = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      go
      go-tools
      hugo      # static website engine
      terraform # infrastructure setup tool
    ];
  };
}
