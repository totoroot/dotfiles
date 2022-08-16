# modules/shell/iperf.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.iperf;
in {
  options.modules.shell.iperf = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Tool to measure IP bandwidth using UDP or TCP
      iperf
    ];

    networking.firewall = {
      allowedTCPPorts = [ 5201 ];
      allowedUDPPorts = [ 5201 ];
    };
  };
}
