# modules/hardware/image.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.image;
in {
  options.modules.hardware.image = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # An open source tool to create bootable USB drive for ISO/WIM/IMG/VHD(x)/EFI files
      ventoy-bin
      # Raspberry Pi Imaging Utility
      rpi-imager
      # Etcher is still somewhat broken on NixOS...see https://github.com/NixOS/nixpkgs/issues/153537
      # Flash OS images to SD cards and USB drives, safely and easily
      # etcher
      # Not yet packaged
      # usbimager
    ];
  };
}
