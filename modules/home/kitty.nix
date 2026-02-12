{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.kitty;
  dotfiles = "/Users/matthias.thym/.config/dotfiles";
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
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/kitty/kitty.conf";
      ".config/kitty/open-actions.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/kitty/open-actions.conf";
    };

    programs.zsh.shellAliases = {
      kssh = "kitty +kitten ssh";
      icat = "kitty +kitten icat";
      hg = "kitty +kitten hyperlinked_grep";
    };
  };
}
