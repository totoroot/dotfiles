{ lib, pkgs, ... }:

{
  imports = [
    ./brew.nix
  ];

  users.users."mathym" = {
    name = "mathym";
    home = "/Users/mathym";
  };

  # Nix configuration ------------------------------------------------------------------------------

  nix = {
    settings = {
      # binaryCaches = [ "https://cache.nixos.org/" ];
      # binaryCachePublicKeys = [
      # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      # ];
      # trustedUsers = [ "@admin" ];
      trusted-substituters = [ "https://devenv.cachix.org" ];
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

    configureBuildUsers = true;
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Fonts
  # fonts.fontDir.enable = true;

  # Keyboard
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  environment.systemPackages = with pkgs; [
    # Firefox
    # firefox-bin
  ];

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # # Create symlinks for nix-darwin packages in ~/Applications
  # system.activationScripts.applications.text = pkgs.lib.mkForce (
  # ''
  # echo "setting up ~/Applications..." >&2
  # rm -rf ~/Applications/NixDarwin
  # mkdir -p ~/Applications/NixDarwin
  # for app in $(find ${config.system.build.applications}/Applications -maxdepth 1 -type l); do
  # src="$(/usr/bin/stat -f%Y "$app")"
  # cp -r "$src" ~/Applications/NixDarwin
  # done
  # ''
  # );
}
