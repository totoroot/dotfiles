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
      cheat               # create and view interactive cheatsheets
      gotop               # graphical activity monitor
      htop                # interactive process viewer
      stress-ng           # stresstest your system
      hyperfine           # benchmark commands
      tree                # directory listing as tree
      pstree   			      # show running processes as tree
      zip				          # create/modify zip archives
      unzip				        # extract zip archives
      exiftool			      # metadata tool
      aria2				        # multi-protocol download utility
      borgbackup          # backup utility with compression and encryption
      playerctl           # control media players from command line
      light               # control display brightness from command line
      colorpicker         # X11 color picker
      jq                  # lightweight JSON processor
      yq                  # jq wrapper for YAML files
      xkbmon              # keyboard layout monitor for X11
      translate-shell     # translator
      speedread           # terminal based reader for maximum wpm
      youtube-dl          # download manager (not only for youtube)
      pulsemixer          # cli mixer for pulseaudio
      ## fetch programs
      neofetch            # fast, highly customizable system info script
      fet-sh              # fetch written in posix shell without any external commands
      pfetch              # pretty system information tool written in POSIX sh
      disfetch            # yet another *nix distro fetching program, but less complex
      ## other fun stuff
      gomatrix			      # matrix effect
      lolcat			        # freakin rainbow terminal effect
      nms 				        # data encryption effect
      pdfcpu			        # cli pdf processor
      pdfpc				        # pdf presenter console
      cheat				        # interactive cheatsheets
      tokei				        # code statistics
      thefuck             # corrects fuckups in console
      nmap                # network discovery utility
      pipes               # animated pipes terminal screensaver
      # Conversion between markup formats
      pandoc
      # Shell script analysis tool
      shellcheck
    ];

    user.extraGroups = [ "admin" ];

    home.configFile = {
      "gotop/gotop.conf".source = "${configDir}/gotop/gotop.conf";
      "pulsemixer.cfg".source = "${configDir}/pulsemixer/pulsemixer.cfg";    };

    environment.shellAliases = {
      gt = "gotop";
      pm = "pulsemixer";
    };
  };
}
