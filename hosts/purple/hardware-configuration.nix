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
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/mnt/photos" = {
    device = "/dev/disk/by-label/photos";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  hardware.video.hidpi.enable = lib.mkDefault true;
}
