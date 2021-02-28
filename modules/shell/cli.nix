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
      unstable.borgbackup # backup utility with compression and encryption
      playerctl           # control media players from command line
      light               # control display brightness from command line
      colorpicker         # X11 color picker
      jq                  # lightweight JSON processor 
      unstable.yq         # jq wrapper for YAML files
      unstable.yamllint   # linter for yaml files
      xkbmon              # keyboard layout monitor for X11
      translate-shell     # translator
      speedread           # terminal based reader for maximum wpm
      unstable.youtube-dl # download manager (not only for youtube)
      pulsemixer          # cli mixer for pulseaudio
      ## file managers
      unstable.lf         # terminal file manager
      ## other fun stuff
      gomatrix			      # matrix effect
      lolcat			        # freakin rainbow terminal effect
      nms 				        # data encryption effect
      pdfcpu			        # cli pdf processor
      pdfpc				        # pdf presenter console
      neofetch			      # system info script
      cheat				        # interactive cheatsheets
      tokei				        # code statistics
      thefuck             # corrects fuckups in console
      nmap                # network discovery utility
    ];

    user.extraGroups = [ "admin" ];

    home.configFile = {
      "gotop/gotop.conf".source = "${configDir}/gotop/gotop.conf";
      "pulsemixer/pulsemixer.cfg".source = "${configDir}/pulsemixer/pulsemixer.cfg";    };

    environment.shellAliases = {
      gt = "gotop";
      pm = "pulsemixer";
    };
  };
}
