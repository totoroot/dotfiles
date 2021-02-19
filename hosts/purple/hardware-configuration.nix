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
      "coretemp"
      "it87"
      "v4l2loopback"
      "rtl8812au"
      "k10temp"
      "fam15h_power"
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
      options = [ "noatime" ];
    };

  fileSystems."/mnt/data" =
    { device = "/dev/disk/by-label/data";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  fileSystems."/mnt/photos" =
    { device = "/dev/disk/by-label/photos";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  # fileSystems."/mnt/vms" =
      # { device = "/dev/disk/by-label/vms";
        # fsType = "ext4";
        # options = [ "noatime" ];
      # };

  swapDevices = [];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
