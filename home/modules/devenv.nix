{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.devenv;
in
{
  options.modules.home.devenv = {
    enable = mkBoolOpt false;
  };

  imports = [ ./zsh.nix ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
    ];

    modules.home.zsh.aliases = {
      dsh = "devenv shell zsh";
      dup = "devenv update";
    };
  };
}
