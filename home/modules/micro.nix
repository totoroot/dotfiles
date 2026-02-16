{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.micro;
  configFile = name: {
    inherit name;
    value = {
      source = "${configDir}/micro/${name}";
      force = true;
    };
  };
in {
  options.modules.home.micro = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Modern and intuitive terminal-based text editor
      micro
    ];

    # environment = {
    #   shellAliases = {
    #     m = "micro";
    #   };
    #   variables = {
    #     MICRO_TRUECOLOR = "1";
    #   };
    # };

    xdg.configFile = builtins.listToAttrs (map configFile [
      "settings.json"
      "bindings.json"
      "init.lua"
      "syntax"
      "colorschemes"
      "plug"
    ]);
  };
}
