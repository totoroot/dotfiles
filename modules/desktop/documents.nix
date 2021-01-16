# modules/desktop/documents.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.documents;
in {
  options.modules.desktop.documents = {
    enable = mkBoolOpt false;
    ebook.enable = mkBoolOpt true;
    office.enable = mkBoolOpt true;
    pdf.enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
    (if cfg.ebook.enable then [
      calibre
    ] else []) ++
    
    (if cfg.office.enable then [
      unstable.libreoffice-fresh  # install latest version of libre office
      pdf2odt                     # pdf to odt/ods converter
    ] else []) ++

    (if cfg.pdf.enable then [
      zathura           # pdf viewer
      qpdfview          # advanced pdf viewer for forms and annotations
      unstable.pdfcpu   # pdf processor
      pdfgrep           # grep for pdf
      unstable.pdfpc    # pdf presenter console
      pdfsandwich       # ocr for pdf
      wkhtmltopdf       # render html to pdf
    ] else []);
  };
}
