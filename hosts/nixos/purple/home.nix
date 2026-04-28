{ ... }:
{
  imports = [
    ../../home/modules/firefox.nix
  ];

  modules.home.firefox.enable = true;
}
