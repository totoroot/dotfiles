{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "zap" removes manually installed brews and casks
      cleanup = "zap";
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
      "ungoogled-chromium"
      "gimp"
      # Offline AI chat tool
	    "jan"
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
      "spotify"
    ];
    taps = [];
  };
  environment.variables = {
     HOMEBREW_NO_UPDATE_REPORT_FORMULAE = "TRUE";
     HOMEBREW_NO_UPDATE_REPORT_CASKS = "TRUE";
  };
}
