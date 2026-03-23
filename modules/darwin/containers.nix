{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.darwin.containers;
in
{
  options.modules.darwin.containers = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    launchd.user.agents = {
      lima-podman = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-lc"
            ''
              if ! ${pkgs.lima}/bin/limactl list -q | ${pkgs.gnugrep}/bin/grep -qx podman; then
                ${pkgs.lima}/bin/limactl start --tty=false --name=podman template:podman
              else
                ${pkgs.lima}/bin/limactl start --tty=false podman
              fi
              ${pkgs.lima}/bin/limactl shell podman -- sh -lc '
                systemctl --user enable --now podman.socket 2>/dev/null \
                  || (mkdir -p "$XDG_RUNTIME_DIR/podman" && \
                      nohup podman system service --time=0 unix://$XDG_RUNTIME_DIR/podman/podman.sock >/tmp/podman-service.log 2>&1 &)
              '
              ${pkgs.lima}/bin/limactl shell podman -- sudo sh -lc '
                mkdir -p /root/.ssh
                cat /home/lima.linux/.ssh/authorized_keys >> /root/.ssh/authorized_keys
                chmod 600 /root/.ssh/authorized_keys
              '
            ''
          ];
          RunAtLoad = true;
          StandardErrorPath = "/tmp/lima-podman.err";
          StandardOutPath = "/tmp/lima-podman.out";
        };
      };
      lima-docker = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-lc"
            ''
              if ! ${pkgs.lima}/bin/limactl list -q | ${pkgs.gnugrep}/bin/grep -qx docker; then
                ${pkgs.lima}/bin/limactl start --tty=false --name=docker template:docker
              else
                ${pkgs.lima}/bin/limactl start --tty=false docker
              fi
            ''
          ];
          RunAtLoad = true;
          StandardErrorPath = "/tmp/lima-docker.err";
          StandardOutPath = "/tmp/lima-docker.out";
        };
      };
    };
  };
}
