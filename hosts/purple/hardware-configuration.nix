{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "ahci" "ohci_pci" "ehci_pci" "xhci_pci" "usb_storage" "usbhid" "uas" "sd_mod" ];
    initrd.kernelModules = [];
    extraModulePackages = [];
    kernelModules = [
      "kvm-amd"
      "coretemp"
      "it87"
      "v4l2loopback"
      "k10temp"
      "fam15h_power"
      "amdgpu"
    ];
    # kernelParams = [
      # "video=HDMI-1:3440x1440@60"
    # ];
  };

  nix.maxJobs = lib.mkDefault 16;
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8c3e271d-84ae-4e4c-b30a-da4a922babf6";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6EAA-309D";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/942e62f5-549c-46f8-8b14-5ee4013de3e5";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  fileSystems."/mnt/data" =
    { device = "/dev/disk/by-uuid/ecea4b71-98e6-4c2a-befb-74bb4f35e39e";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  fileSystems."/mnt/photos" =
    { device = "/dev/disk/by-uuid/0ee239aa-88cd-4a40-a697-19beef515c0f";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  swapDevices = [ { device = "/dev/disk/by-uuid/81651822-eb2c-4670-9b64-263386393b9a"; } ];

  hardware.video.hidpi.enable = lib.mkDefault true;
}
