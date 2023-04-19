{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    loader = {
      # NixOS wants to enable GRUB by default
      grub.enable = false;
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
    # A bunch of boot parameters needed for optimal runtime on RPi 3b+
    kernelParams = [ "cma=256M" ];
    # Clean /tmp on startup
    tmp.cleanOnBoot = true;
  };
}
