{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.docker;
in
{
  options.modules.services.docker = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      docker
      docker-compose
      # Simple terminal UI for docker and docker-compose
      lazydocker
      # Top-like interface for container metrics
      ctop
      # A tool for exploring each layer in a docker image
      dive
    ];

    env.DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
    env.MACHINE_STORAGE_PATH = "$XDG_DATA_HOME/docker/machine";

    user.extraGroups = [ "docker" ];

    home-manager.users.${config.user.name}.modules.home.zsh.rcFiles =
      [ "${configDir}/docker/aliases.zsh" ];

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;
    };
  };
}
