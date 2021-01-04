# modules/shell/taskell.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.taskell;
in {
  options.modules.shell.taskell = {
    enable  = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      taskell
    ];

    home.configFile = {
      "taskell/bindings.ini".source = "${configDir}/taskell/bindings.ini";
      "taskell/config.ini".source = "${configDir}/taskell/config.ini";
      "taskell/template.md".source = "${configDir}/taskell/template.md";
      "taskell/theme.ini".source = "${configDir}/taskell/theme.ini";
    };
  };
}
