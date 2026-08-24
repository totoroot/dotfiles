{ ... }:
{
  imports = [
    ../../home/modules/firefox.nix
  ];

  modules.home.firefox.enable = true;
  modules.home.qownnotes.enable = true;
}
