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

  # programs.zsh = {
  #   enable = true;
  #   enableCompletion = true;
  #   # enableAutosuggestions = true;
  #   initExtraBeforeCompInit = ''
  #     fpath+=("${config.home.profileDirectory}"/share/zsh/site-functions \
  #             "${config.home.profileDirectory}"/share/zsh/$ZSH_VERSION/functions \
  #             "${config.home.profileDirectory}"/share/zsh/vendor-completions)
  #   '';
  # };

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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # I init completion myself, because enableGlobalCompInit initializes it
    # too soon, which means commands initialized later in my config won't get
    # completion, and running compinit twice is slow.
    # enableGlobalCompInit = false;
    # promptInit = "";
	sessionVariables = {
	  ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
	  ZSH_CACHE = "$XDG_CACHE_HOME/zsh";
	  ZGENOM_DIR = "$XDG_DATA_HOME/zsh";
	  ZGENOM_SOURCE = "$ZGENOM_DIR/zgenom.zsh";
	};
  };
  modules.home = {
    atuin.enable = true;
    duf.enable = true;
    git.enable = true;
    gitlab-cli.enable = true;
    fonts.enable = true;
    kitty.enable = true;
    kubernetes.enable = true;
    micro.enable = true;
    nushell.enable = true;
    trash.enable = true;
    unfreePackages.enable = true;
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

  # home.file =
  #   with pkgs; let
  #     listFilesRecursive = dir: acc: lib.flatten (lib.mapAttrsToList
  #       (k: v: if v == "regular" then "${acc}${k}" else listFilesRecursive dir "${acc}${k}/")
  #       (builtins.readDir "${dir}/${acc}"));
  #
  #     toHomeFiles = dir:
  #       builtins.listToAttrs
  #         (map (x: {
  #         	name = ".config/${x}";
  #         	value = {
  #             source = "${dir}/${x}";
  #             force = true;
  #         };
  #         }) (listFilesRecursive dir ""));
  #   in toHomeFiles ../../../config;
}
