{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.micro;
in {
  options.modules.editors.micro = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      unstable.micro
    ];
    environment.shellAliases = {
      m = "micro";
    };
    home.configFile = {
      "micro/settings.json".source = "${configDir}/micro/settings.json";
      "micro/bindings.json".source = "${configDir}/micro/bindings.json";
      "micro/syntax".source = "${configDir}/micro/syntax";
    };
  };
}
