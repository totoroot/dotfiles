{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.radeon;
in {
  options.modules.hardware.radeon = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    hardware.graphics.enable = true;
    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        # OpenCL ICD definition for AMD GPUs using the ROCm stack
        rocmPackages.clr.icd
        # OpenCL runtime for AMD GPUs, part of the ROCm stack
        rocmPackages.clr
        # AMD Open Source Driver For Vulkan
        amdvlk
        # Hardware-accelerated video playpack
        # VDPAU driver for the VAAPI library
        vaapiVdpau
        # VDPAU driver with OpenGL/VAAPI backend
        libvdpau-va-gl
        # Tool to query the Video Decode and Presentation API for Unix (VDPAU) abilities of the system
        vdpauinfo
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
      # ROCm Application for Reporting System Info
      rocmPackages.rocminfo
      # System management interface for AMD GPUs supported by ROCm
      rocmPackages.rocm-smi
      # Platform runtime for ROCm
      rocmPackages.rocm-runtime
      # CMake modules for common build tasks for the ROCm stack
      rocmPackages.rocm-cmake
      # Radeon open compute thunk interface
      rocmPackages.rocm-thunk
    ];
  };
}
