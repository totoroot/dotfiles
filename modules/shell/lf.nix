# modules/shell/lf.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.lf;
in {
  options.modules.shell.lf = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      lf
      bat
      unrar
      poppler
      unzip
      imagemagick
      catdoc
      ffmpegthumbnailer
      chafa
      odt2txt
      exiftool
      transmission
      gnumeric
    ];
      
    home.configFile = {
      "lf/lfrc".source = "${configDir}/lf/lfrc";
    };
  };
}
