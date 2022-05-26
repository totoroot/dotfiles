{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.cli;
in {
  options.modules.shell.cli = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ## System utilities
      # Command line tool for the desktop trash can
      trash-cli
      # Create and view interactive cheatsheets
      cheat
      # Graphical activity monitor
      gotop
      # Interactive process viewer
      htop
      # Resource monitor; python port of bashtop
      bpytop
      # Stresstest your system
      stress-ng
      # Benchmark commands
      hyperfine
      # Directory listing as tree
      tree
      # Show running processes as tree
      pstree
      # Create/modify zip archives
      zip
      # Extract zip archives
      unzip
      # Metadata tool
      exiftool
      # Multi-protocol download utility
      aria2
      # Control media players from command line
      playerctl
      # Control display brightness from command line
      light
      # X11 color picker
      colorpicker
      # small utility to create JSON objects
      jo
      # Lightweight JSON processor
      jq
      # jq wrapper for YAML files
      yq
      # Keyboard layout monitor for X11
      xkbmon
      # Translator
      translate-shell
      # Terminal based reader for maximum wpm
      speedread
      # Download manager (not only for youtube)
      # unstable.youtube-dl
      unstable.yt-dlp
      # CLI mixer for pulseaudio
      pulsemixer

      ## Fetch programs
      # Fast, highly customizable system info script
      neofetch
      # Fetch written in posix shell without any external commands
      fet-sh
      # Pretty system information tool written in POSIX sh
      pfetch
      # Yet another *nix distro fetching program, but less complex
      disfetch
      ## Other fun stuff
      # Matrix effect
      gomatrix
      # Freakin rainbow terminal effect
      lolcat
      # Data encryption effect
      nms
      # Cli PDF processor
      pdfcpu
      # Code statistics
      tokei
      # Corrects fuckups in console
      thefuck
      # Network discovery utility
      nmap
      # Animated pipes terminal screensaver
      pipes
      # Conversion between markup formats
      pandoc
      # Shell script analysis tool
      shellcheck
      # HTML validator and 'tidier'
      html-tidy
      # Cross-platform CLI csv pretty printer that uses column styling to maximize viewer enjoyment
      tidy-viewer
    ];

    user.extraGroups = [ "admin" ];

    home.configFile = {
      "gotop/gotop.conf".source = "${configDir}/gotop/gotop.conf";
      "bpytop/bpytop.conf".source = "${configDir}/bpytop/bpytop.conf";
      "pulsemixer.cfg".source = "${configDir}/pulsemixer/pulsemixer.cfg";
      "cheat/conf.yml".source = "${configDir}/cheat/conf.yml";
    };

    environment.shellAliases = {
      gt = "gotop";
      pm = "pulsemixer";
      rm = "trash";
      rst = "trash-restore";
    };
  };
}
