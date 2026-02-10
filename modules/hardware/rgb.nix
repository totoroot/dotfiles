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
    boot = {
      kernelModules = [ "eeprom" "ee1004" "i2c-core" "i2c-dev" "i2c-piix4" ];
      kernelParams = [
        "acpi_enforce_resources=lax"
        "pci=assign-busses"
      ];
    };
    hardware.i2c.enable = true;
    services = {
      # udev.packages = [ pkgs.openrgb-with-all-plugins ];
      hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb.overrideAttrs (old: {
          src = pkgs.fetchFromGitLab {
            owner = "CalcProgrammer1";
            repo = "OpenRGB";
            rev = "release_candidate_1.0rc1";
            # rev = "release_candidate_1.0rc2";
            hash = "sha256-jKAKdja2Q8FldgnRqOdFSnr1XHCC8eC6WeIUv83e7x4=";
            # hash = "sha256-vdIA9i1ewcrfX5U7FkcRR+ISdH5uRi9fz9YU5IkPKJQ=";
          };
          # The postPatch in nixpkgs is meant for v0.9 of OpenRGB, but the upstream is
          # more like a 1.1-ish thing, and the udev rules script changed.
          postPatch = ''
            patchShebangs scripts/build-udev-rules.sh
            substituteInPlace scripts/build-udev-rules.sh \
              --replace-fail /usr/bin/env "${pkgs.coreutils}/bin/env"
          '';
        });
        motherboard = "amd";
      };
    };
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
