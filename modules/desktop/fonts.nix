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
        dejavu_fonts
        symbola
        noto-fonts
        # emojione
        fira
        fira-code-symbols
        siji
        font-awesome
        source-code-pro
        source-han-mono
        source-han-sans
        source-han-serif
        source-sans-pro
        source-serif-pro
        corefonts
        vista-fonts
      ];
    };

    fonts.fontconfig.defaultFonts = {
      sansSerif = [ "Fira Sans" ];
      monospace = [ "Mononoki" ];
    };
  };
}
