{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.ghostty;
  dotfilesDir = "${config.xdg.configHome}/dotfiles";
in
{
  options.modules.home.ghostty = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ghostty-bin
    ];

#     home.file = {
#       ".config/kitty/kitty.conf".source =
#         config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/kitty/kitty.conf";
#     };
#
#     programs.zsh.shellAliases = {
#       kssh = "kitty +kitten ssh";
#       icat = "kitty +kitten icat";
#       hg = "kitty +kitten hyperlinked_grep";
#     };
  };
}
