# modules/desktop/media/graphics.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.graphics;
in {
  options.modules.desktop.media.graphics = {
    enable         = mkBoolOpt false;
    raster.enable  = mkBoolOpt true;
    photo.enable   = mkBoolOpt true;
    vector.enable  = mkBoolOpt true;
    sprites.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      (if cfg.enable then [
        imv           # simplest image viewer
        qview         # simple image viewer
        imagemagick   # console image manipulation tool
      ] else []) ++

      (if cfg.raster.enable then [
        unstable.krita
        unstable.gimp
        # gimpPlugins.resynthesizer2  # content-aware scaling in gimp
      ] else []) ++

      (if cfg.vector.enable then [
        unstable.inkscape
      ] else []) ++

      (if cfg.photo.enable then [
        unstable.darktable
      ] else []) ++

      (if cfg.sprites.enable then [
        aseprite-unfree
      ] else []);

    home.configFile = mkIf cfg.raster.enable {
      "GIMP/2.10" = { source = "${configDir}/gimp"; recursive = true; };
    };
  };
}
