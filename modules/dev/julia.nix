# modules/dev/julia.nix

{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let cfg = config.modules.dev.julia;
in {
  options.modules.dev.julia = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # High-level performance-oriented dynamical language for technical computing
      unstable.julia-bin
      # A monospaced font for scientific and technical computing
      julia-mono
    ];
  };
}
