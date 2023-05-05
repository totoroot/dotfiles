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
      "curl"
      "displayplacer"
      "findutils"
      "gawk"
      "go"
      "gnutls"
      "gnu-getopt"
      "gnu-indent"
      "gnu-sed"
      "gnu-tar"
      "gotop"
      "kube-ps1"
      "micro"
      "nushell"
      "qemu"
      "watch"
      "podman"
      "ydiff"
      "trash-cli"
      "starship"
      # "helm"
      # "kubebuilder" # generating k8s controller
      # "skhd" # keybinding manager
      # "openstackclient"
      # # broken nix builds
      # "starship"
      # "yabai" # tiling window manager
    ];
    casks = [
      # Advanced file renaming utility
      "a-better-finder-rename"
      # Window switcher
      "alt-tab"
      # Better search menu than Spotlight
      "alfred"
      # Utility for writing image files
      "balenaetcher"
      "betterdisplay"
      # Multi-protocol storage browser
      "cyberduck"
      # Ungoogled Chromium
      "eloston-chromium"
      # Monitoring widget
      "eul"
      # Keyboard layout for Europeans, coders and translators
      "eurkey"
      # "fig"
      "font-fira-code"
      "font-fira-mono"
      "font-fira-sans"
      "font-juliamono"
      # Small and lightweight IDE
      "geany"
      # The GNU Image Manipulation Program
      "gimp"
      "gpg-suite"
      # Order, toggle and hide menu bar icons
      "hiddenbar"
      "iterm2"
      # Tiny menu bar calendar
      "itsycal"
      "julia"
      # Keymap remap utility
      "karabiner-elements"
      # Offline password manager with many features
      "keepassxc"
      "kitty"
      "krita"
      "libreoffice"
      "maccy"
      "macdown"
      "macs-fan-control"
      "notion"
      "obs"
      # "osxfuse"
      "rectangle"
      "sensiblesidebuttons"
      "signal"
      # Don't quit apps accidentally with Cmd+Q
      "slowquitapps"
      "vscodium"
      "webex"
      "xquartz"
    ];
    taps = [
      # Default Taps
      "homebrew/bundle"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
      "dteoh/sqa"
      "jakehilborn/jakehilborn"
      "koekeishiya/formulae"
      "muesli/tap"
      "stelligent/tap"
    ];
  };
}
