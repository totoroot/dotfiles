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
      supertux
      # Free 3D kart racing game
      supertuxkart
      # Multi-platform emulator frontend for libretro cores
      retroarch
    ];
  };
}
