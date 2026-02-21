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
    ../../../home/modules/home-manager-applications-fix.nix
    ../../../home/bridge.nix
    ./packages.nix
  ];

  home.packages = with pkgs; [
    # Some basics
    coreutils
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

  home.sessionPath = [
    "$HOME/.config/dotfiles/bin"
  ];

  modules.home = {
    unfreePackages.enable = true;
    atuin.enable = true;
    duf.enable = true;
    git.enable = true;
    gitlab-cli.enable = true;
    fonts.enable = true;
    helix.enable = true;
    kitty.enable = true;
    kubernetes.enable = true;
    lf.enable = true;
    micro.enable = true;
    nushell.enable = true;
    sshHosts = {
      enable = true;
      defaultUser = "mathym";
      defaultIdentityFile = "~/.ssh/private";
    };
    trash.enable = true;
    viddy.enable = true;
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
