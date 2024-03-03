{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.sensors;
in {
  options.modules.hardware.sensors = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Tools for reading hardware sensors
      lm_sensors
      # A tool that reads information about your system's hardware from the BIOS according to the SMBIOS/DMI standard
      dmidecode
    ];
  };
}
