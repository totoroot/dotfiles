# modules/hardware/rgb.nix

{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.hardware.rgb;
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

    for i in $(seq 0 $(($NUM_DEVICES - 1))); do
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color 000000
    done
  '';
in
{
  options.modules.hardware.rgb = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.udev.packages = [ pkgs.openrgb-with-all-plugins ];
    boot.kernelModules = [ "eeprom" "ee1004" "i2c-core" "i2c-dev" "i2c-piix4" ];
    hardware.i2c.enable = true;

    systemd.services.no-rgb = {
      description = "no-rgb";
      serviceConfig = {
        ExecStart = "${no-rgb}/bin/no-rgb";
        Type = "oneshot";
      };
      wantedBy = [ "multi-user.target" ];
    };
    environment.systemPackages = with pkgs; [
      i2c-tools
    ];
  };
}
