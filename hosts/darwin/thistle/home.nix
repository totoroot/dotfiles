{ ... }:

{
  home = {
    username = "mathym";
    stateVersion = "25.11";
  };

  imports = [
    ../../../home/modules/home-manager-applications-fix.nix
    ../../../home/bridge.nix
    ./packages.nix
  ];

  modules.home.darwinCommon = {
    enable = true;
    defaultUser = "mathym";
    enableContainers = true;
    enableGhostty = true;
  };

  modules.home.gitlab-cli.enable = true;

  programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
