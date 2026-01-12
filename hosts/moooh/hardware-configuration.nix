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
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    # kernelPackages = pkgs.linuxPackages_latest.extend (self: super: {
    #   ipu6-drivers = super.ipu6-drivers.overrideAttrs (
    #     final: previous: rec {
    #       src = builtins.fetchGit {
    #         url = "https://github.com/intel/ipu6-drivers.git";
    #         ref = "master";
    #         rev = "b4ba63df5922150ec14ef7f202b3589896e0301a";
    #       };
    #       patches = [
    #         "${src}/patches/0001-v6.10-IPU6-headers-used-by-PSYS.patch"
    #       ];
    #     }
    #   );
    # });
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
}
