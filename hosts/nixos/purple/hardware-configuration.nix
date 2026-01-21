{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "ahci"
        "ohci_pci"
        "ehci_pci"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "uas"
        "sd_mod"
        "cryptd"
      ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices = {
        "home" = {
          device = "/dev/disk/by-uuid/914272cf-c2ab-41ff-8bd6-2c0dc0bed305";
          preLVM = true;
        };
      };
      supportedFilesystems = [ "btrfs" ];
    };
    supportedFilesystems = [ "btrfs" ];
    extraModulePackages = [ ];
    kernelModules = [
      "kvm-amd"
      "coretemp"
      "it87"
      "v4l2loopback"
      "k10temp"
      "fam15h_power"
      "amdgpu"
    ];
  };

  nix.settings.max-jobs = lib.mkDefault 16;

  powerManagement.cpuFreqGovernor = "ondemand";

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
