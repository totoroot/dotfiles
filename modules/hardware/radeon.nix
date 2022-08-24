{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.radeon;
in {
  options.modules.hardware.radeon = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };

    services.xserver.videoDrivers = [ "amdgpu" ];

    user.packages = with pkgs; [
      # Inspect and manipulate PCI devices
      pciutils
      # Print all known information about all available OpenCL platforms and devices in the system
      clinfo
      # Top-like tool for viewing AMD Radeon GPU utilization
      radeontop
      # Application to read current clocks of AMD Radeon cards
      radeon-profile
    ];
  };
}
