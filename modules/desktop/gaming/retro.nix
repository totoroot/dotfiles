# modules/desktop/gaming/retro.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.gaming.retro;
in {
  options.modules.desktop.gaming.retro = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Classic 2D jump'n run sidescroller game
      superTux
      # Free 3D kart racing game
      # TODO currently broken
      # See https://github.com/NixOS/nixpkgs/issues/445447
      # superTuxKart
      # Multi-platform emulator frontend for libretro cores
      retroarch
    ];
  };
}
