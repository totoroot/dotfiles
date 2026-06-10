{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (final: prev: {
    inherit (prev.lixPackageSets.latest)
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena;
  }) ];

  nix = {
    package = pkgs.lixPackageSets.latest.lix;

    settings = {
      nix-path = [ ];
      substituters = [
        "https://cache.nixos.org/"
        "https://devenv.cachix.org"
        "https://nixpkgs-python.cachix.org"
      ];
      trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
      ];
    };

    extraOptions = ''
      # Linking issue: https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = false
      keep-going = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "x86_64-darwin") ''
      extra-platforms = x86_64-darwin
    '';

    gc = {
      automatic = true;
      interval = { Day = 7; };
      options = "--delete-older-than 30d";
    };
  };

  programs.zsh.enable = true;

  system.stateVersion = 6;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
