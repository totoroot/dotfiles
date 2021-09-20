{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.nvidia;
in {
  options.modules.hardware.nvidia = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    hardware.opengl.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    services.xserver.screenSection = ''
        Option "metamodes" "DP-0: nvidia-auto-select +0+2160, DP-2: nvidia-auto-select +0+0"
    '';

    services.xserver.deviceSection = ''
      Option "Coolbits" "28"
    '';

    environment.systemPackages = with pkgs; [
      nvidia-video-sdk  # needed for NVENC support in OBS
      # nvidia-docker     # NVIDIA container runtime for Docker
      
      # Respect XDG conventions, damn it!
      (writeScriptBin "nvidia-settings" ''
        #!${stdenv.shell}
        mkdir -p "$XDG_CONFIG_HOME/nvidia"
        exec ${config.boot.kernelPackages.nvidia_x11.settings}/bin/nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings"
      '')
    ];
    
    user.packages = with pkgs; [
      pciutils          # inspect and manipulate PCI devices
      nvtop    # task monitor for Nvidia GPUs
    ];
  };
}
