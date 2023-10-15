{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.gaming.emulators;
in {
  options.modules.desktop.gaming.emulators = {
    ps1.enable = mkBoolOpt false; # Playstation
    ps2.enable = mkBoolOpt false; # Playstation 2
    ds.enable = mkBoolOpt false; # Nintendo DS
    gb.enable = mkBoolOpt false; # GameBoy + GameBoy Color
    gba.enable = mkBoolOpt false; # GameBoy Advance
    snes.enable = mkBoolOpt false; # Super Nintendo
  };

  config = {
    user.packages = with pkgs; [
      (mkIf cfg.ps1.enable pcsxr)
      (mkIf cfg.ps2.enable pcsx2)
      (mkIf cfg.ds.enable desmume)
      (mkIf
        (cfg.gba.enable ||
          cfg.gb.enable ||
          cfg.snes.enable)
        higan)
    ];
  };
}
