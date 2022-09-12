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

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8c3e271d-84ae-4e4c-b30a-da4a922babf6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6EAA-309D";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/5dfc5e4e-943f-4d31-8e9c-d4f6be6e2c5c";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-uuid/7e000029-709f-4098-a72d-7faab49ca2db";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/mnt/photos" = {
    device = "/dev/disk/by-uuid/0ee239aa-88cd-4a40-a697-19beef515c0f";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/81651822-eb2c-4670-9b64-263386393b9a"; } ];

  hardware.video.hidpi.enable = lib.mkDefault true;
}
