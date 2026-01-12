{ config, lib, pkgs, modulesPath, ... }:

let
  boot_device_uuid = "/dev/disk/by-uuid/";
  root_device_uuid = "/dev/disk/by-uuid/";
in

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "uas"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "thunderbolt"
        "vmd"
        "aesni_intel"
        "cryptd"
      ];
      kernelModules = [
        "dm-snapshot"
        "i915"
      ];
      luks.devices."nixos" = {
        device = "${root_device_uuid}";
        # preLVM = true;
        allowDiscards = true;
      };
    };
    resumeDevice = "${root_device_uuid}";
    supportedFilesystems = [ "btrfs" ];
    kernelModules = [
      "kvm-intel"
      "1915"
    ];
    kernelParams = [
      # Something, something swapfile
      "resume_offset=101861376"
      # needed for Intel Iris Xe
      "i915.force_probe=46a8"
      "i915.enable_guc=3"
      "i915.fastboot=1"
      # needed for keyboard
      "i8042.dumbkbd=1"
      "i8042.nopnp=1"
    ];
    extraModulePackages = [ ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.auto-cpufreq = {
    # Failed assertions:
    # - You have set services.power-profiles-daemon.enable = true;
    # which conflicts with services.auto-cpufreq.enable = true;
    enable = false;
    # settings = {
    #   battery = {
    #     governor = "powersave";
    #     turbo = "never";
    #   };
    #   charger = {
    #     governor = "performance";
    #     turbo = "auto";
    #   };
    # };
  };

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  hardware.graphics.extraPackages = with pkgs; [
    intel-vaapi-driver
    libvdpau-va-gl
    intel-media-driver
  ];

  # services.fprintd = {
  #   enable = true;
  #   package = pkgs.fprintd-tod;
  #   tod = {
  #     enable = true;
  #     driver = pkgs.libfprint-2-tod1-broadcom;
  #   };
  # };

  services.fstrim.enable = true;

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };

  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [
    # Mount remote directories over SSH
    sshfs
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    # "/" = {
    #   device = "/dev/disk/by-label/nixos";
    #   fsType = "btrfs";
    #   options = [ "subvol=root" "compress=zstd" "noatime" ];
    # };
    # "/home" = {
    #   device = "/dev/disk/by-label/nixos";
    #   fsType = "btrfs";
    #   options = [ "subvol=home" "compress=zstd" "noatime" ];
    # };
    # "/nix" = {
    #   device = "/dev/disk/by-label/nixos";
    #   fsType = "btrfs";
    #   options = [ "subvol=nix" "compress=zstd" "noatime" ];
    # };
    # "/persist" = {
    #   device = "/dev/disk/by-label/nixos";
    #   fsType = "btrfs";
    #   options = [ "subvol=persist" "compress=zstd" "noatime" ];
    #   neededForBoot = true;
    # };
    # "/var/log" = {
    #   device = "/dev/disk/by-label/nixos";
    #   fsType = "btrfs";
    #   options = [ "subvol=log" "compress=zstd" "noatime" ];
    #   # Needed for correct log order
    #   neededForBoot = true;
    # };
    "/boot" = {
      device = "${boot_device_uuid}";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/swap"; }];
}
