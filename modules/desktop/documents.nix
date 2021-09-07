# modules/desktop/documents.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.documents;
in {
  options.modules.desktop.documents = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      libreoffice-fresh   # install latest version of libre office
      pdf2odt             # pdf to odt/ods converter
      zathura             # pdf viewer
      qpdfview            # advanced pdf viewer for forms and annotations
      unstable.pdfcpu     # pdf processor
      pdfgrep             # grep for pdf
      pdfpc      # pdf presenter console
      pdfsandwich         # ocr for pdf
      wkhtmltopdf         # render html to pdf
      xournalpp           # handwriting notetaking software with PDF annotation support
      xfce.mousepad       # simple text editor for Xfce
    ];
  };
}
