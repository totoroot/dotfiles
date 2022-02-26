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
      ## system utilities
      # create and view interactive cheatsheets
      cheat
      # graphical activity monitor
      gotop
      # interactive process viewer
      htop
      # resource monitor; python port of bashtop
      bpytop
      # stresstest your system
      stress-ng
      # benchmark commands
      hyperfine
      # directory listing as tree
      tree
      # show running processes as tree
      pstree
      # create/modify zip archives
      zip
      # extract zip archives
      unzip
      # metadata tool
      exiftool
      # multi-protocol download utility
      aria2
      # backup utility with compression and encryption
      borgbackup
      # control media players from command line
      playerctl
      # control display brightness from command line
      light
      # X11 color picker
      colorpicker
      # small utility to create JSON objects
      jo
      # lightweight JSON processor
      jq
      # jq wrapper for YAML files
      yq
      # keyboard layout monitor for X11
      xkbmon
      # translator
      translate-shell
      # terminal based reader for maximum wpm
      speedread
      # download manager (not only for youtube)
      youtube-dl
      # cli mixer for pulseaudio
      pulsemixer
      ## fetch programs
      # fast, highly customizable system info script
      neofetch
      # fetch written in posix shell without any external commands
      fet-sh
      # pretty system information tool written in POSIX sh
      pfetch
      # yet another *nix distro fetching program, but less complex
      disfetch
      ## other fun stuff
      # matrix effect
      gomatrix
      # freakin rainbow terminal effect
      lolcat
      # data encryption effect
      nms
      # cli pdf processor
      pdfcpu
      # pdf presenter console
      pdfpc
      # code statistics
      tokei
      # corrects fuckups in console
      thefuck
      # network discovery utility
      nmap
      # animated pipes terminal screensaver
      pipes
      # conversion between markup formats
      pandoc
      # shell script analysis tool
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
    };

    environment.shellAliases = {
      gt = "gotop";
      pm = "pulsemixer";
    };
  };
}
