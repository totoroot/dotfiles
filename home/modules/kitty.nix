{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.kitty;
in
{
  options.modules.home.kitty = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;
    modules.home.configSymlinks.entries = [
      "kitty/kitty.conf"
      "kitty/open-actions.conf"
    ];

    home.packages = with pkgs; [
      kitty
    ];

    programs.zsh.shellAliases = {
      kssh = "kitty +kitten ssh";
      icat = "kitty +kitten icat";
      hg = "kitty +kitten hyperlinked_grep";
    };
  };
}
