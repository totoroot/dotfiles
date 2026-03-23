{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.containers;
in
{
  options.modules.home.containers = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Docker CLI + plugins (no Docker Desktop)
      docker
      docker-compose
      docker-buildx
      # Podman tooling
      podman
      podman-compose
      # VM backends for macOS
      # Colima: simplest way to run Docker (and optionally Podman) on macOS.
      colima
      # Lima: general VM manager; used if you want separate VMs for Podman and Docker.
      lima
      podman-desktop
    ];

    modules.home.zsh.rcInit = mkAfter ''
      if [[ "$(uname -s)" == "Darwin" ]]; then
        if [[ -f "$HOME/.lima/docker/ssh.config" ]]; then
          export DOCKER_HOST="ssh://lima-docker"
        fi

        if [[ -f "$HOME/.lima/podman/ssh.config" ]]; then
          podman_host="$(
            /usr/bin/awk '
              $1 == "Host" && $2 == "lima-podman" { in_block=1; next }
              $1 == "Host" { in_block=0 }
              in_block && $1 == "Hostname" { host=$2 }
              in_block && $1 == "Port" { port=$2 }
              END { if (host && port) printf "%s:%s", host, port }
            ' "$HOME/.lima/podman/ssh.config"
          )"
          podman_identity="$(
            /usr/bin/awk '
              $1 == "Host" && $2 == "lima-podman" { in_block=1; next }
              $1 == "Host" { in_block=0 }
              in_block && $1 == "IdentityFile" { print $2; exit }
            ' "$HOME/.lima/podman/ssh.config" | tr -d '"'
          )"
          if [[ -n "$podman_host" ]]; then
            export PODMAN_HOST="ssh://root@''${podman_host}/run/podman/podman.sock"
          fi
          if [[ -n "$podman_identity" ]]; then
            export PODMAN_SSH_COMMAND="ssh -i ''${podman_identity} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes"
          fi
        fi
      fi
    '';

    programs.ssh.includes = mkIf pkgs.stdenv.isDarwin (mkAfter [
      "~/.lima/docker/ssh.config"
      "~/.lima/podman/ssh.config"
    ]);

    home.activation.ensureLimaPodmanConnection = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [[ "$(uname -s)" == "Darwin" ]]; then
        if [[ -f "$HOME/.lima/podman/ssh.config" ]]; then
          podman_host="$(
            /usr/bin/awk '
              $1 == "Host" && $2 == "lima-podman" { in_block=1; next }
              $1 == "Host" { in_block=0 }
              in_block && $1 == "Hostname" { host=$2 }
              in_block && $1 == "Port" { port=$2 }
              END { if (host && port) print host ":" port }
            ' "$HOME/.lima/podman/ssh.config"
          )"
          podman_identity="$(
            /usr/bin/awk '
              $1 == "Host" && $2 == "lima-podman" { in_block=1; next }
              $1 == "Host" { in_block=0 }
              in_block && $1 == "IdentityFile" { print $2; exit }
            ' "$HOME/.lima/podman/ssh.config" | tr -d '"'
          )"
          if [[ -n "$podman_host" ]]; then
            if ! ${pkgs.podman}/bin/podman system connection exists lima-podman >/dev/null 2>&1; then
              ${pkgs.podman}/bin/podman system connection add lima-podman \
                "ssh://root@''${podman_host}/run/podman/podman.sock" \
                --identity "''${podman_identity}" >/dev/null 2>&1 || true
            fi
            ${pkgs.podman}/bin/podman system connection default lima-podman >/dev/null 2>&1 || true
          fi
        fi
      fi
    '';

    home.activation.ensureLimaDockerContext = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [[ "$(uname -s)" == "Darwin" ]]; then
        if [[ -f "$HOME/.lima/docker/ssh.config" ]]; then
          if ! ${pkgs.docker}/bin/docker context inspect lima-docker >/dev/null 2>&1; then
            ${pkgs.docker}/bin/docker context create lima-docker \
              --docker "host=ssh://lima-docker" >/dev/null 2>&1 || true
          fi
          ${pkgs.docker}/bin/docker context use lima-docker >/dev/null 2>&1 || true
        fi
      fi
    '';
  };
}
