{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "uas"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "thunderbolt"
        "vmd"
      ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices."nixos" = {
        device = "/dev/disk/by-uuid/47d8eafe-895e-474d-884a-de19eaf31a6c";
        preLVM = true;
        keyFile = "/keyfile.bin";
        allowDiscards = true;
      };
      secrets = {
        "keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
        # grub = {
          # enable = true;
          # device = "nodev";
          # efiSupport = true;
          # enableCryptodisk = true;
        # };
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
