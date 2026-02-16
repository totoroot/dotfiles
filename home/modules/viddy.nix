{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.viddy;
in
{
  options.modules.home.viddy = with types; {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      viddy
    ];

    modules.home.configSymlinks.entries =
      map (name: "viddy/${name}") [
        "viddy.toml"
      ];

    home.shellAliases = {
      # vd = "(){viddy -d -n 1 --shell zsh \"$(which $1 | cut -d' ' -f 4-)\${@:2}\";}";
      vd = "(){viddy -d -n 1 \"$*\"}";
    };
  };
}
