{ config, lib, pkgs, modulesPath, ... }:

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
      ];
      kernelModules = [];
    };
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
  };

  nix.settings.max-jobs = lib.mkDefault 16;

  powerManagement.cpuFreqGovernor = "ondemand";

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
