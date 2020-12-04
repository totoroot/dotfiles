# modules/desktop/documents.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.documents;
in {
  options.modules.desktop.documents = {
    enable = mkBoolOpt false;
    ebook.enable = mkBoolOpt false;
    office.enable = mkBoolOpt true;
    pdf.enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
    (if cfg.ebook.enable then [
      calibre
    ] else []) ++
    
    (if cfg.office.enable then [
      libreoffice-fresh   # install latest version of libre office
      pdf2odt             # pdf to odt/ods converter
    ] else []) ++

    (if cfg.pdf.enable then [
      pdfcpu        # pdf processor
      pdfgrep       # grep for pdf
      pdfpc         # pdf presenter console
      pdfsandwich   # ocr for pdf
      wkhtmltopdf   # render html to pdf
      zathura       # pdf viewer
    ] else []);
  };
}
