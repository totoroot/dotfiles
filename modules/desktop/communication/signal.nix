{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.communication.signal;
in {
  options.modules.desktop.communication.signal = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Private, simple, and secure messenger
      signal-desktop
      # Command-line and dbus interface for communicating with the Signal messaging service
      signal-cli
    ];
  };
}
