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
      direnv
      nix-direnv
    ];

    modules.home.zsh.rcInit = ''eval "$(direnv hook zsh)"'';

    env.DIRENV_LOG_FORMAT = "";

    environment.shellAliases = {
      dsh = "devenv shell zsh";
      dup = "devenv update";
    };
  };
}
