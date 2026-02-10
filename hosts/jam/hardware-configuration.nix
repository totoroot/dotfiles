{ modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
        "cryptd"
      ];
      kernelModules = [ "dm-snapshot" ];
      supportedFilesystems = [ "btrfs" ];
    };
    supportedFilesystems = [ "btrfs" ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # virtualisation.qemu.guestAgent.enable = true;
  services.qemuGuest.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  swapDevices = [ ];

  zramSwap.enable = true;
}
