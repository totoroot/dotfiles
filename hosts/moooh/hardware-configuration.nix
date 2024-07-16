{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
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
        device = "/dev/disk/by-uuid/47d8eafe-895e-474d-884a-de19eaf31a6c";
        preLVM = true;
        keyFile = "/keyfile.bin";
        allowDiscards = true;
      };
      secrets = {
        "keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";
      };
    };
    kernelModules = [
      "kvm-intel"
      "1915"
    ];
    kernelParams = [
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
        efiSysMountPoint = "/boot/efi";
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
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  hardware.graphics.extraPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl
    intel-media-driver
  ];

  services.fprintd = {
    enable = false;
    tod = {
      enable = false;
      # driver = pkgs.fork.libfprint-2-tod1-broadcom;
    };
  };

  services.fstrim.enable = true;

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };
}
