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
	./fonts.nix
	./packages.nix
    ../../../home/modules
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

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  programs.starship.enable = true;

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
  modules.home.atuin.enable = true;
  modules.home.duf.enable = true;
  modules.home.git.enable = true;
  modules.home.gitlab-cli.enable = true;
  modules.home.kitty.enable = true;
  modules.home.kubernetes.enable = true;
  modules.home.micro.enable = true;
  modules.home.nushell.enable = true;
  modules.home.trash.enable = true;
  modules.home.unfreePackages.enable = true;
  modules.home.viddy.enable = true;
  modules.home.zsh.enable = true;

  home.file = {
    # Downloaded from https://github.com/jonasdiemer/EurKEY-Mac
    "Library/Keyboard Layouts/EurKEY.keylayout".source = ../../../config/eurkey/EurKEY.keylayout;
    "Library/Keyboard Layouts/EurKEY.icns".source = ../../../config/eurkey/EurKEY.icns;
	# Cute icon for kitty terminal emulator
    "Applications/kitty.app/Contents/Resources/kitty.icns".source = ../../../config/kitty/kitty-dark.icns;
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
