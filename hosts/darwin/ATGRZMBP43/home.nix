{ config, pkgs, ... }:

let
  configDir = "$HOME/.config";
in
{
  home = {
    username = "matthias.thym";
    stateVersion = "25.11";
  };

  imports = [
    ./packages.nix
    ../../../home/bridge.nix
  ];

  home.packages = with pkgs; [
    # Some basics
    coreutils
    curl
    wget
    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    # comma # run software from without installing it
    niv # easy dependency management for nix projects
  ] ++ lib.optionals stdenv.isDarwin [
    cocoapods
    m-cli # useful macOS CLI commands
  ];

  home.sessionVariables = {
    HOMEBREW_NO_INSTALL_CLEANUP = "TRUE";
    EDITOR = "micro";
  };

  modules.home = {
    atuin.enable = true;
    duf.enable = true;
    git.enable = true;
    gitlab-cli.enable = true;
    fonts.enable = true;
    helix.enable = true;
    kitty.enable = true;
    kubernetes.enable = true;
    micro.enable = true;
    nushell.enable = true;
    trash.enable = true;
    unfreePackages.enable = true;
    viddy.enable = true;
    vim = {
      enable = true;
      desktop.enable = false;
    };
    zsh.enable = true;
  };

  home.file = {
    # Downloaded from https://github.com/jonasdiemer/EurKEY-Mac
    "Library/Keyboard Layouts/EurKEY.keylayout".source = ../../../config/eurkey/EurKEY.keylayout;
    "Library/Keyboard Layouts/EurKEY.icns".source = ../../../config/eurkey/EurKEY.icns;
	# Cute icon for kitty terminal emulator
    "Applications/kitty.app/Contents/Resources/kitty.icns".source = ../../../config/kitty/kitty-dark.icns;
    # Silence last login messages in terminal
    ".hushlogin".text = "";
  };
}
