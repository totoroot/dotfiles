{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.nushell;
in
{
  options.modules.home.nushell = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;
    home.packages = with pkgs; [
      # Modern shell written in Rust
      nushell
    ];

    modules.home.configSymlinks.entries =
      map (name: "nushell/${name}") [
        "config.nu"
        "env.nu"
      ];
  };
}
