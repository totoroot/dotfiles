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
      # Comprehensive, professional-quality productivity suite, a variant of openoffice.org
      libreoffice-fresh
      # PDF to ODT/ODS converter
      pdf2odt
      # Highly customizable and functional PDF viewer
      zathura
      # Advanced PDF viewer for forms and annotated documents
      qpdfview
      # CLI PDF processor
      pdfcpu
      # CLI utility to search text in PDF files
      pdfgrep
      # Presenter console with multi-monitor support for PDF files
      pdfpc
      # OCR tool for scanned PDFs
      pdfsandwich
      # Tools for rendering web pages to PDF or images
      # wkhtmltopdf
      # Handwriting notetaking software with PDF annotation support
      xournalpp
      # Simple GUI text editor
      xfce.mousepad
      # GNU/Linux-friendly version of the Wacom Inkling SketchManager
      inklingreader
      # Simple drawing application to create handwritten notes
      rnote
    ];
  };
}
