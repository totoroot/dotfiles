{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let hwCfg = config.modules.hardware;
    cfg = hwCfg.bluetooth;
in {
  options.modules.hardware.bluetooth = {
    enable = mkBoolOpt false;
    audio.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    { hardware.bluetooth.enable = true; }

    (mkIf cfg.audio.enable {
      hardware.pulseaudio = {
        # NixOS allows either a lightweight build (default) or full build of
        # PulseAudio to be installed.  Only the full build has Bluetooth
        # support, so it must be selected here.
        # Also install bluetooth cli tools to make it usable.
        package = with pkgs; [
          pulseaudioFull
          bluez
          bluez-tools
          blueman
        ];
        # Enable additional codecs
        extraModules = [ pkgs.pulseaudio-modules-bt ];
      };

      hardware.bluetooth.extraConfig = ''
        [General]
        Enable=Source,Sink,Media,Socket
      '';
    })
  ]);
}
