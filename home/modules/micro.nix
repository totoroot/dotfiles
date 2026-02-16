{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.micro;
in {
  options.modules.home.micro = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;

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

    modules.home.configSymlinks.entries =
      map (name: "micro/${name}") [
        "settings.json"
        "bindings.json"
        "init.lua"
        "syntax"
        "colorschemes"
        "plug"
      ];
  };
}
