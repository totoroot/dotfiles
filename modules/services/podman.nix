{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.podman;
in
{
  options.modules.services.podman = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Program for managing pods, containers and container images
      podman
      # Podman Terminal UI
      podman-tui
      # Implementation of docker-compose with podman backend
      podman-compose
      # Top-like interface for container metrics
      ctop
      # A tool for exploring each layer in a docker image
      dive
    ];

    virtualisation.podman = {
      enable = true;
      # Expose a Docker-compatible CLI only when the Docker module is not enabled.
      dockerCompat = !config.virtualisation.docker.enable;
    };
  };
}
