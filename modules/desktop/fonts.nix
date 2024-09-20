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
      # Highly customizable and minimal CLI font previewer
      fontpreview
      # Simple font management GUI for GTK desktop environments
      font-manager
      # Font editor
      fontforge
    ];

    fonts = {
      fontDir.enable = true;
      enableGhostscriptFonts = true;
      packages = with pkgs; [
        ubuntu_font_family
        dejavu_fonts
        symbola
        noto-fonts
        carlito
        # emojione
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
        comic-mono
      ];
    };

    fonts.fontconfig.defaultFonts = {
      sansSerif = [ "Fira Sans" ];
      monospace = [ "Mononoki" ];
    };
  };
}
