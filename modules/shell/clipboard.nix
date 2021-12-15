# modules/shell/clipboard.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.clipboard;
in {
  options.modules.shell.clipboard = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      haskellPackages.greenclip
    ];

    home.configFile = {
      "greenclip.toml".source = "${configDir}/greenclip/greenclip.toml";
    };

    environment.shellAliases = {
      clip = "greenclip print | sed '/^$/d' | fzf -e | xargs -r -d'\n' -I '{}' greenclip print '{}'";
    };
  };
}
