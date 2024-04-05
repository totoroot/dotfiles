{ pkgs, ... }:

{
  env.GREET = "Welcome to the development shell for totoroot's dotfiles";

  packages = with pkgs; [
    git
    # Packages for hooks
    deadnix
    mdl
    nixpkgs-fmt
    shellcheck
  ];

  scripts.greeting.exec = "echo $GREET";

  enterShell = ''
    greeting
  '';

  languages.nix.enable = true;

  pre-commit = {
    hooks = {
      deadnix = {
        enable = true;
        settings.hidden = true;
      };
      mdl.enable = true;
      nixpkgs-fmt.enable = true;
      shellcheck.enable = true;
    };
  };
}
