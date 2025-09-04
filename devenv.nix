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

  git-hooks = {
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

  scripts = {
    nixup.exec = "sudo nixos-rebuild switch --flake .#$(hostname) --impure";
    nixupC2.exec = "sudo nixos-rebuild switch --flake .#$(hostname) --impure --max-jobs 2 --cores 2";
  };
}
