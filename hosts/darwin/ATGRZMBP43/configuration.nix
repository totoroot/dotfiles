# nix-darwin configuration
{ lib, pkgs, ... }:

{
  imports = [
    ./brew.nix
  ];

  users.users."matthias.thym" = {
    name = "matthias.thym";
    home = "/Users/matthias.thym";
  };

  system.primaryUser = "matthias.thym";
  system.stateVersion = 6;

  # Nix configuration ------------------------------------------------------------------------------

  nixpkgs.overlays = [ (final: prev: {
    inherit (prev.lixPackageSets.latest)
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena;
  }) ];

  nix = {
    # Use Lix
    package = pkgs.lixPackageSets.latest.lix;

    settings = {
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

    # Enable experimental nix command and flakes
    extraOptions = ''
      # Linking issue: https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = false
      # keep-outputs = true
      # keep-derivations = true
      # keep-failed = false
      keep-going = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "x86_64-darwin") ''
      extra-platforms = x86_64-darwin
    '';

    # Optimise storage by enabling automatic garbage collection
    gc = {
      automatic = true;
      interval = { Day = 7; };
      options = "--delete-older-than 30d";
    };
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Keyboard
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
}
