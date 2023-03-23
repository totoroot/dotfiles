{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.audio;
in {
  options.modules.hardware.audio = {
    enable = mkBoolOpt false;
    pipewire = mkBoolOpt true;
    pulseaudio = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Enable ALSA sound
      sound.enable = true;

      # RealtimeKit system service provides
      # realtime scheduling priority to user processes on demand
      # Required by the audio server
      security.rtkit.enable = true;

      user.extraGroups = [ "audio" ];

      user.packages = with pkgs; [
        # PulseAudio Volume Control
        pavucontrol
        # Audio visualizer
        cava
        # Virtual microphone device with noise supression for PulseAudio
        noisetorch
        (makeDesktopItem {
          name = "noisetorch";
          desktopName = "NoiseTorch";
          genericName = "Virtual Microphone";
          icon = "microphone";
          exec = "${noisetorch}/bin/noisetorch";
          categories = [ "Audio" ];
        })
        # CLI mixer for PulseAudio
        pulsemixer
      ];

      home.configFile = {
        "pulsemixer.cfg".source = "${configDir}/pulsemixer/pulsemixer.cfg";
        "cava/config".source = "${configDir}/cava/config";
      };

      environment.shellAliases.pm = "pulsemixer";
    }

    # PipeWire Configuration
    (mkIf cfg.pipewire {
      services.pipewire = {
        # Wireplumber session/policy manager is enabled by default
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = true;
      };
      user.packages = with pkgs; [
        # Audio effects for PipeWire applications
        easyeffects
      ];
    })

    # PulseAudio Sound Server Configuration (legacy)
    (mkIf cfg.pulseaudio {
      hardware.pulseaudio = {
        enable = true;
        # HACK Prevents ~/.esd_auth files by disabling the esound protocol module
        #      for pulseaudio, which I likely don't need. Is there a better way?
        configFile =
          let inherit (pkgs) runCommand pulseaudio;
            paConfigFile =
              runCommand "disablePulseaudioEsoundModule"
                { buildInputs = [ pulseaudio ]; } ''
                  mkdir "$out"
                  cp ${pulseaudio}/etc/pulse/default.pa "$out/default.pa"
                  sed -i -e 's|load-module module-esound-protocol-unix|# ...|' "$out/default.pa"
                '';
          in mkIf config.hardware.pulseaudio.enable
            "${paConfigFile}/default.pa";
      };

      user.packages = with pkgs; [
        # PulseAudio Preferences GUI
        paprefs
        # PulseAudio CLI
        pulseaudio-ctl
      ];
    })
  ]);
}
