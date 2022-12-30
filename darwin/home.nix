{ config, pkgs, ... }:

{
  home.stateVersion = "22.05";

  imports = [
    ./packages.nix
    ./fonts.nix
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # enableAutosuggestions = true;
    initExtraBeforeCompInit = ''
      fpath+=("${config.home.profileDirectory}"/share/zsh/site-functions \
              "${config.home.profileDirectory}"/share/zsh/$ZSH_VERSION/functions \
              "${config.home.profileDirectory}"/share/zsh/vendor-completions)
    '';
  };

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
}
