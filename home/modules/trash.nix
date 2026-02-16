{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.home.trash;
in {
  options.modules.home.trash = {
    enable = mkBoolOpt false;
  };

  imports = [
    ./config-symlinks.nix
    ./zsh.nix
  ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Command line trash / recycle bin utilities
      trash-cli
    ];

    modules.home.zsh.aliases = {
      rm = "trash-put";
      rst = "trash-restore";
      restore = "trash-list | fzf --multi | awk '{$1=$1;print}' | rev | cut -d ' ' -f1 | rev | xargs trash-restore";
      empty = "trash-empty";
    };
  };
}
