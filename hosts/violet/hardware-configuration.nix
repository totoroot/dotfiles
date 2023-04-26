{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "ehci_pci"
        "nvme"
        "usb_storage"
        "usbhid"
        "uas"
        "sd_mod"
      ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [
      "kvm-amd"
      "amdgpu"
    ];
    extraModulePackages = [ ];
  };

  nix.settings.max-jobs = lib.mkDefault 4;

  powerManagement.cpuFreqGovernor = "powersave";

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
