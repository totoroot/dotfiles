# modules/desktop/vscodium.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.vscodium;
in {
  options.modules.desktop.vscodium = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      (vscode-with-extensions.override {
        # Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing)
        vscode = vscodium;
        # Wrapped variant of vscodium which launches in a FHS compatible envrionment. Should allow for easy usage of extensions without nix-specific modifications.
        # vscode = vscodium-fhs
        # A couple useful VSCode/VSCodium extension
        vscodeExtensions = with vscode-extensions; [
          # Dracula theme for VSCode
          dracula-theme.theme-dracula
          # Personal knowledge management and sharing system for VSCode
          foam.foam-vscode
          # Nix language support with formatting and error report
          jnoortheen.nix-ide
          # Extension that lets you use environments declared in .nix files in Visual Studio Code.
          arrterian.nix-env-selector
          # Rich support for Python
          # ms-python.python
          # Jupyter notebooks
          ms-toolsai.jupyter
          # Generates python docstrings automatically
          njpwerner.autodocstring
          # Show PDF preview
          tomoki1207.pdf
          # See Git Blame info in status bar
          waderyan.gitblame
          # Hard wrap
          stkb.rewrap
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
          name = "vscode-reveal";
          publisher = "evilz";
          version = "4.3.3";
          sha256 = "sha256-KqvQi0DMfHppX96qKHIkO9zIueBdGGV+6dYkpFEzFBo=";
        }];
      })
    ];
  };
}
