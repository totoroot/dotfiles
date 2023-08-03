{ pkgs, ... }:

{
  env.GREET = "Welcome to the development shell for totoroot's dotfiles";

  packages = with pkgs; [
    git
    deadnix
  ];

  scripts.greeting.exec = "echo $GREET";

  enterShell = ''
    greeting
  '';

  languages.nix.enable = true;

  pre-commit = {
    hooks = {
      deadnix.enable = true;
      markdownlint.enable = false;
      shellcheck.enable = true;
    };
    settings = {
      deadnix = {
        hidden = true;
      };
    };
  };
}
