# modules/services/kdeconnect.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.kdeconnect;
in {
  options.modules.services.kdeconnect = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libsForQt5.kdeconnect-kde
    ];

    networking.firewall = {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };
  };
}
