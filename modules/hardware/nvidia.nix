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
        Option "metamodes" "HDMI-0: nvidia-auto-select +200+0, DP-0: nvidia-auto-select +0+1440"
    '';

    services.xserver.deviceSection = ''
      Option "Coolbits" "28"
    '';

    environment.systemPackages = with pkgs; [
      # NVIDIA Video Codec SDK (needed for NVENC support in OBS)
      # nvidia-video-sdk

      # Respect XDG conventions, damn it!
      (writeScriptBin "nvidia-settings" ''
        #!${stdenv.shell}
        mkdir -p "$XDG_CONFIG_HOME/nvidia"
        exec ${config.boot.kernelPackages.nvidia_x11.settings}/bin/nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings"
      '')
    ];

    user.packages = with pkgs; [
      # Inspect and manipulate PCI devices
      pciutils
      # Task monitor for Nvidia GPUs
      nvtop
    ];
  };
}
