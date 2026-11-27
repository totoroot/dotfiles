{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.devenv;
in {
  options.modules.shell.devenv = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      devenv
    ];

    environment.shellAliases = {
      dsh = "devenv shell zsh";
      dup = "devenv update";
    };
  };
}
