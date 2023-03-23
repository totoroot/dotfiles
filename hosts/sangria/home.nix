{ config, pkgs, ... }:

{
  imports = [
  ];

  fonts.fontconfig.enable = true;

  home = {
    username = "mathym";
    homeDirectory = "/home/mathym";
    stateVersion = "22.11";

    packages = with pkgs; [
      gotop
      neofetch
      micro
      pfetch
    ];
  };

  programs = {
    home-manager.enable = true;
    helix.enable = true;
    micro.enable = true;
    gpg.enable = true;
    fzf.enable = true;
    jq.enable = true;
    # bat.enable = true;
    command-not-found.enable = true;
    dircolors.enable = true;
    htop.enable = true;
    info.enable = true;
    exa.enable = true;
    kitty.enable = true;
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    git = {
      enable = true;
      userEmail = "git@thym.at";
      userName = "totoroot";
    };
  };
}
