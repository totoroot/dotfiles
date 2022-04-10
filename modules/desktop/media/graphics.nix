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
        # Software suite to create, edit, compose, or convert bitmap images
        imagemagick
        # Command line image viewer for tiling window managers
        imv
        # Practical and minimal image viewer
        qview
        # Qt5 image viewer with optional video support
        qimgv
        # Qt-based image viewer
        nomacs
      ] else []) ++

      (if cfg.raster.enable then [
        # Free and open source painting application
        krita
        # The GNU Image Manipulation Program
        gimp
        # Content-aware scaling in gimp
        gimpPlugins.resynthesizer
      ] else []) ++

      (if cfg.vector.enable then [
        # Vector graphics editor
        inkscape-with-extensions
      ] else []) ++

      (if cfg.photo.enable then [
        # Virtual lighttable and darkroom for photographers
        darktable
      ] else []) ++

      (if cfg.sprites.enable then [
        # Animated sprite editor & pixel art tool
        aseprite
      ] else []);

    home.configFile = mkIf cfg.raster.enable {
      "GIMP/2.10" = { source = "${configDir}/gimp"; recursive = true; };
    };
  };
}
