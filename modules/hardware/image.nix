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
      # See https://github.com/NixOS/nixpkgs/issues/404663 and
      # https://github.com/ventoy/Ventoy/issues/3224
      # ventoy
      # Raspberry Pi Imaging Utility
      # TODO fix failed build
      # rpi-imager
      # Very minimal GUI app that can write compressed disk images to USB drives
      usbimager
      # Etcher is marked as insecure on NixOS...see https://github.com/NixOS/nixpkgs/issues/153537#issuecomment-1115961395
      # Flash OS images to SD cards and USB drives, safely and easily
      # etcher
      # Multiple USB File Flasher
      popsicle
    ];

    environment.shellAliases = {
      # In case we really need Etcher
      etcher = "NIXPKGS_ALLOW_INSECURE=1 nix run nixpkgs#etcher --impure";
      # Currently I'm fine with ventoy using blobs as I don't want to [attribute to malice that
      # that which is adequately explained by stupidity](https://en.wikipedia.org/wiki/Hanlon's_razor).
      ventoy = "NIXPKGS_ALLOW_INSECURE=1 nix run nixpkgs#ventoy";
    };
  };
}
