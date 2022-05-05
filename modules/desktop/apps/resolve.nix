{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.resolve;
in {
  options.modules.desktop.apps.resolve = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Issues with Radeon graphics cards
      # See this issue: https://github.com/NixOS/nixpkgs/pull/152113
      unstable.davinci-resolve
    ];
  };
}
