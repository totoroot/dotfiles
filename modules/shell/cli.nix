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
      # A utility that combines the usability of The Silver Searcher with the raw speed of grep
      ripgrep
      # Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more
      ripgrep-all
      # Create and view interactive cheatsheets
      cheat
      # Graphical activity monitor
      gotop
      # Interactive process viewer
      htop
      # Resource monitor
      btop
      # Stresstest your system
      stress-ng
      # Benchmark commands
      hyperfine
      # Directory listing as tree
      tree
      # Show running processes as tree
      pstree
      # Collection of common network programs (including telnet, hostname, ifconfig)
      inetutils
      # Utility for controlling network drivers and hardware
      ethtool
      # Implements Wake On LAN functionality in a small program
      wol
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
      # Small utility to create JSON objects
      jo
      # Faster implementation of the lightweight JSON processor
      gojq
      # jq wrapper for YAML files
      yq
      # Keyboard layout monitor for X11
      xkbmon
      # Translator
      translate-shell
      # Terminal based reader for maximum wpm
      speedread
      # Download manager (not only for youtube)
      yt-dlp
      # A modern watch command
      viddy
      # Shell history with encrypted synchronisation between machines
      atuin
      # Shell script analysis tool
      shellcheck
      # HTML validator and 'tidier'
      html-tidy
      # Cross-platform CLI csv pretty printer that uses column styling to maximize viewer enjoyment
      tidy-viewer
      # Disk usage analyzer with an ncurses interface
      ncdu
      # A tool to check markdown files and flag style issues
      mdl
      # Cli PDF processor
      pdfcpu
      # Code statistics
      tokei
      # Small, fast and powerful console music player
      cmus

      ## Fetch programs
      # neofetch with pride flags <3
      hyfetch
      # Pretty system information tool written in Rust
      pfetch-rs
      # neofetch but for IP addresses
      ipfetch

      ## Communication tools
      # Command-line and dbus interface for communicating with the Signal messaging service
      signal-cli

      ## Document tools
      # Conversion between markup formats
      pandoc
      # PDF processor
      pdfcpu

      ## Other fun stuff
      # Matrix effect
      gomatrix
      # Freakin rainbow terminal effect
      clolcat
      # Data encryption effect
      nms
      # Corrects fuckups in console
      thefuck
      # Network discovery utility
      pipes
      # A fast, async, stream-based link checker written in Rust
      lychee
      # A fast cd command that learns your habits
      zoxide
    ];

    user.extraGroups = [ "admin" ];

    home.configFile = {
      "gotop/gotop.conf".source = "${configDir}/gotop/gotop.conf";
      "btop/btop.conf".source = "${configDir}/btop/btop.conf";
      "cheat/conf.yml".source = "${configDir}/cheat/conf.yml";
      "markdownlint" = {
        recursive = true;
        source = "${configDir}/markdownlint";
      };
      "viddy.toml".source = "${configDir}/viddy/viddy.toml";
    };

    environment.shellAliases = {
      gt = "gotop";
      jq = "gojq";
      rm = "trash";
      rst = "trash-restore";
      dui = "ncdu --color dark -rr -x --exclude .git";
      mdl = "mdl -c ${configDir}/markdownlint/mdlrc";
      markdownlint = "mdl -c ${configDir}/markdownlint/mdlrc";
      vd = "(){viddy -d -n 1 --shell zsh  \"$(which $1 | cut -d' ' -f 4-)\${@:2}\";}";
      lolcat = "clolcat";
      colorpick = "print '\nPicking color in 5 seconds...\n' && sleep 5 && colorpicker --short --one-shot | tr -d '\n' | xclip -sel clip && xclip -sel clip -o";
    };
  };
}
