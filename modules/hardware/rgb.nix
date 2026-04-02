# modules/hardware/rgb.nix

{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.hardware.rgb;
  no-rgb = pkgs.writeScriptBin "no-rgb" ''
    #!/bin/sh
    set -eu

    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

    if [ "$NUM_DEVICES" -eq 0 ]; then
      exit 0
    fi

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
    boot = {
      kernelModules = [ "eeprom" "ee1004" "i2c-core" "i2c-dev" "i2c-piix4" ];
      kernelParams = [
        "acpi_enforce_resources=lax"
      ];
    };
    hardware.i2c.enable = true;
    services = {
      hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb;
        motherboard = "amd";
      };
    };
    systemd.services.no-rgb = {
      description = "no-rgb";
      after = [ "openrgb.service" ];
      wants = [ "openrgb.service" ];
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
