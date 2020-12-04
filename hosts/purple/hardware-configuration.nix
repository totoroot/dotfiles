{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "xhci_pci" "usbhid" "uas" "sd_mod" ];
    initrd.kernelModules = [];
    extraModulePackages = [];
    kernelModules = [
      "kvm-amd"
      "asix"  # REVIEW Remove me when 5.9 kernel is available
    ];
  };

  # CPU
  nix.maxJobs = lib.mkDefault 16;
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.amd.updateMicrocode = true;

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/home";
      fsType = "ext4";
      options = [ "noatime"];
    };

  fileSystems."/mnt/music" =
    { device = "/dev/disk/by-label/music";
      fsType = "ext4";
    };

  swapDevices = [];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
