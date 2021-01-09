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
      unstable.go
      unstable.go-tools
      unstable.hugo      # static website engine
      unstable.terraform # infrastructure setup tool
    ];
  };
}
