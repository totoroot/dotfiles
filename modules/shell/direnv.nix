{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.direnv;
in {
  options.modules.shell.direnv = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      direnv
      nix-direnv
      devenv
    ];
    modules.shell.zsh.rcInit = ''eval "$(direnv hook zsh)"'';
  };
}
