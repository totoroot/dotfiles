{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    loader = {
      # Use the latest kernel
      kernelPackages = pkgs.linuxPackages_latest;
      # GRUB is enabled by default
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
      # Config for Raspberry Pis
      raspberryPi = {
        enable = true;
        version = 3;
        uboot = {
          enable = true;
          configurationLimit = 10;
        };
        firmwareConfig = ''
          gpu_mem=256
        '';
      };
    };
    # A bunch of boot parameters needed for optimal runtime on RPi 3B+
    kernelParams = [ "cma=256M" ];
    # Make the camera available as v4l device under /dev/video0
    kernelModules = [ "bcm2835-v4l2" ];
    # Clean /tmp on startup
    tmp.cleanOnBoot = true;
  };
}
