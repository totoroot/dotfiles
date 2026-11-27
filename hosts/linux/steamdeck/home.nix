{ pkgs, ... }:

{
  imports = [
    ../../../modules/editors
    ../../../home/modules/direnv.nix
  ];

  fonts.fontconfig.enable = true;

  home = {
    username = "deck";
    homeDirectory = "/home/deck";
    stateVersion = "22.11";

    packages = with pkgs; [
      gotop
      fastfetch
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
    eza.enable = true;
    bash.enable = true;
    kitty.enable = true;
    git = {
      enable = true;
      settings.user = {
        email = "git@thym.at";
        name = "totoroot";
      };
    };
  };
}
