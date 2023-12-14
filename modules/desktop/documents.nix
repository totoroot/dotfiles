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

      # error: builder for '/nix/store/v76sg0q8rhlzkgwwq1rp545iydlnzmc1-python2.7-wheel-0.37.1.drv' failed with exit code 1;
      # last 10 log lines:
      # > stripping (with command strip and flags -S -p) in  /nix/store/mfmj7m941b9vyccljic6c52nsfnd42b6-python2.7-wheel-0.37.1/lib /nix/store/mfmj7m941b9vyccljic6c52nsfnd42b6-python2.7-wheel-0.37.1/bin
      # > Rewriting #!/nix/store/sg8jaxzkipg3kyahi2n3v8zw83ydx6gx-python-2.7.18.7/bin/python2.7 to #!/nix/store/sg8jaxzkipg3kyahi2n3v8zw83ydx6gx-python-2.7.18.7
      # > wrapping `/nix/store/mfmj7m941b9vyccljic6c52nsfnd42b6-python2.7-wheel-0.37.1/bin/wheel'...
      # > Executing pythonRemoveTestsDir
      # > Finished executing pythonRemoveTestsDir
      # > pythonCatchConflictsPhase
      # >   File "/nix/store/qzdnf36li7zrnr95dhpc1w1i61ifw4s6-catch_conflicts.py", line 16
      # >     f"{dist._normalized_name} {dist.version} ({dist._path})"
      # >                                                            ^
      # > SyntaxError: invalid syntax
      # For full logs, run 'nix log /nix/store/v76sg0q8rhlzkgwwq1rp545iydlnzmc1-python2.7-wheel-0.37.1.drv'.
      # error: 1 dependencies of derivation '/nix/store/04h3ndcbb0mw9vl22nfmx1yaqn2qbz5r-setuptools-setup-hook.drv' failed to build
      # error: 1 dependencies of derivation '/nix/store/c5wqjjyk8f3awa1fbxz51v9aq1jcj9fl-resholve-0.9.0.drv' failed to build
      # error: 1 dependencies of derivation '/nix/store/k72ic00qlbv1qbyxyl13mcdk9l6sfzkk-pdf2odt-20170207.drv' failed to build
      # error (ignored): error: cannot unlink '/tmp/nix-build-aws-sdk-cpp-1.11.118.drv-1/source': Directory not empty
      # error: 1 dependencies of derivation '/nix/store/20mmj8k11rqhyzhrawa1mgklg5if6php-user-environment.drv' failed to build
      # error: 1 dependencies of derivation '/nix/store/kkgqbmd8qb0ffv5vwinpnzcy4lmg6z2d-etc.drv' failed to build
      # error: 1 dependencies of derivation '/nix/store/88d96vpsm1ssm5dpifpxs7j5cn7b5pxc-nixos-system-violet-23.11.20231117.c757e9b.drv' failed to build

      # pdf2odt

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
