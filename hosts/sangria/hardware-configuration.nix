{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ohci_pci"
        "ehci_pci"
        "ahci"
        "firewire_ohci"
        "nvme"
        "uas"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sr_mod"
        "sdhci_pci"
      ];
      kernelModules = [ "kvm-intel" "wl" ];
    };
    kernelModules = [ ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    loader.efi.efiSysMountPoint = "/boot/efi";
  };

  powerManagement.cpuFreqGovernor = "powersave";

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
