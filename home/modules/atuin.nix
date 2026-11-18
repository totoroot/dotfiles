{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.atuin;
  configDir = "${config.home.homeDirectory}/${config.modules.home.configSymlinks.destination}/atuin";
in
{
  options.modules.home.atuin = {
    enable = mkBoolOpt false;
  };

  imports = [ ./config-symlinks.nix ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;
    modules.home.configSymlinks.force = true;
    # Newer Atuin versions can prefer ~/.atuin/config.toml over the managed link.
    home.sessionVariables.ATUIN_CONFIG_DIR = configDir;
    home.activation.ensureAtuinDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${configDir}"
    '';
    home.packages = with pkgs; [
      # Replacement for a shell history which records additional commands
      # context with optional encrypted synchronization between machines
      atuin
    ];

    modules.home.configSymlinks.entries =
      map (name: "atuin/${name}") [
        "config.toml"
      ];
  };
}
