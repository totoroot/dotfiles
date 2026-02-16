{ pkgs, ... }:

{
  imports = [
    ../../../home/bridge.nix
  ];

  home = {
    username = "mathym";
    homeDirectory = "/home/mathym";
    stateVersion = "25.11";
  };

  modules.home = {
    git.enable = true;
    kitty.enable = true;
    micro.enable = true;
    unfreePackages.enable = true;
    zsh.enable = true;
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    curl
    wget
  ];
}
