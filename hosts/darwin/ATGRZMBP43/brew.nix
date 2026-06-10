{ config, lib, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "zap" removes manually installed brews and casks
      cleanup = "zap";
      extraFlags = [ "--force" ];
      extraEnv = {
        # nix-darwin runs `brew bundle` via a separate `env brew bundle ...`
        # activation command, so global environment.variables are not applied
        # to that subprocess. Set this here so bundle/fetch avoid the broken
        # Homebrew API cask path and use tap-based resolution instead.
        HOMEBREW_NO_INSTALL_FROM_API = "1";
      };
    };
    brews = [
      # CLI tool for executing mouse- and keyboard-related actions
      "cliclick"
      "gnu-getopt"
      "gnu-indent"
      "kube-ps1"
      "qemu"
      "podman"
      "displayplacer"
    ];
    casks = [
      # Advanced file renaming utility
      #"a-better-finder-rename"
      # Ungoogled Chromium
      # "ungoogled-chromium"
      "gimp"
      # Offline AI chat tool
	    # "jan"
      # Keyboard layout for Europeans, coders and translators
      "eurkey"
      "gpg-suite"
      # Order, toggle and hide menu bar icons
      "hiddenbar"
      # Free and open source painting application
      "krita"
      "obs"
      "sensiblesidebuttons"
      "xquartz"
      "lunar"
      "kitty"
      "inkscape"
      "vscodium"
      "siyuan"
      "android-studio"
      "tidal"
    ];
    taps = [];
  };
  environment.variables = {
    HOMEBREW_NO_UPDATE_REPORT_FORMULAE = "TRUE";
    HOMEBREW_NO_UPDATE_REPORT_CASKS = "TRUE";
    # Keep this for interactive `brew` usage too. The actual nix-darwin
    # activation path needs the matching `homebrew.onActivation.extraEnv`
    # override above.
    HOMEBREW_NO_INSTALL_FROM_API = "1";
  };

  environment.systemPath = lib.mkAfter [
    "/opt/homebrew/bin"
  ];

  home-manager.users.${config.system.primaryUser}.programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
