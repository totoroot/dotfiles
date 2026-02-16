{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.helix;
in
{
  options.modules.home.helix = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;

    home.packages = with pkgs; [
      # Post-modern modal text editor
      helix
    ];

    programs.zsh.shellAliases = {
      helix = "hx";
    };

    modules.home.configSymlinks.entries =
      map (name: "helix/${name}") [
        "config.toml"
      ];
  };
}
