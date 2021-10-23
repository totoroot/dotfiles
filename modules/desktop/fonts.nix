# modules/desktop/fonts.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.fonts;
in {
  options.modules.desktop.fonts = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      fontpreview   # highly customizable and minimal CLI font previewer
      font-manager   # simple font management GUI for GTK desktop environments
      fontforge     # a font editor
    ];

    fonts = {
      fontDir.enable = true;
      enableGhostscriptFonts = true;
      fonts = with pkgs; [
        ubuntu_font_family
        dejavu_fonts
        symbola
        noto-fonts
        carlito
        emojione
        fira
        fira-code
        fira-code-symbols
        fira-mono
        mononoki
        julia-mono
        jetbrains-mono
        siji
        font-awesome
        hack-font
        lato
        source-code-pro
        source-han-mono
        source-han-sans
        source-han-serif
        source-sans-pro
        source-serif-pro
        corefonts
        vistafonts
      ]; 
    };
  };
}
