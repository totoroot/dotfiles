# modules/hardware/mcus.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.mcus;
in {
  options.modules.hardware.mcus = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # ESP8266 and ESP32 serial bootloader utility
      esptool
      # Python implementation for MCUs
      micropython
    ];
  };
}
