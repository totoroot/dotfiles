{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.containerization;
in {
  options.modules.services.containerization = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      docker
      docker-compose
      # Program for managing pods, containers and container images
      podman
      # Podman Terminal UI
      podman-tui
      # Implementation of docker-compose with podman backend
      podman-compose
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

    modules.shell.zsh.rcFiles = [ "${configDir}/docker/aliases.zsh" ];

    # For misbehaving containers that delay shutdowns and reboots
    # TODO - The option definition `systemd.extraConfig' in `/nix/store/1lci8fdzlpzbwa3gkh8zgpxryjrwn250-source' no longer has any effect; please remove it. Use systemd.settings.Manager instead.
    # systemd.extraConfig = ''
    #   DefaultTimeoutStopSec=10s
    # '';

    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = true;
        autoPrune.enable = true;
        # listenOptions = [];
      };
      podman = {
        enable = true;
        # Create a `docker` alias for podman, to use it as a drop-in replacement
        # dockerCompat = true;
      };
    };
  };
}
