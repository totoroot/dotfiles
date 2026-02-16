{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.kitty;
  dotfilesDir = "${config.xdg.configHome}/dotfiles";
in
{
  options.modules.home.kitty = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kitty
    ];

    home.file = {
      ".config/kitty/kitty.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/kitty/kitty.conf";
      ".config/kitty/open-actions.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/kitty/open-actions.conf";
    };

    programs.zsh.shellAliases = {
      kssh = "kitty +kitten ssh";
      icat = "kitty +kitten icat";
      hg = "kitty +kitten hyperlinked_grep";
    };
  };
}
