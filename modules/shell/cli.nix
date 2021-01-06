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
      gotop           # graphical activity monitor
      zenith          # zoomable system monitor
      tree            # directory listing as tree
      pstree   			  # show running processes as tree
      sd 				      # intuitive sed alternative
      fd 				      # intuitive find alertnative
      nvtop				    # task monitor for Nvidia GPUs
      zip				      # create/modify zip archives
      unzip				    # extract zip archives
      exiftool			  # metadata tool
      aria2				    # multi-protocol download utility
      borgbackup		  # backup utility with compression and encryption
      playerctl       # control media players from command line
      light           # control display brightness from command line
      colorpicker     # X11 color picker
      ## file managers
      lf              # terminal file manager
      ## other fun stuff
      gomatrix			  # matrix effect
      lolcat			    # freakin rainbow terminal effect
      nms 				    # data encryption effect
      pdfcpu			    # cli pdf processor
      pdfpc				    # pdf presenter console
      neofetch			  # system info script
      cheat				    # interactive cheatsheets
      tokei				    # code statistics
    ];

    user.extraGroups = [ "admin" ];
  };
}
