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

  nix.settings.max-jobs = lib.mkDefault 16;

  powerManagement.cpuFreqGovernor = "performance";

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.video.hidpi.enable = lib.mkDefault true;
}
