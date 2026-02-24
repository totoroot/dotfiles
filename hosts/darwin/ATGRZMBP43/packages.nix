{ pkgs, inputs, lib, ... }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
{
  modules.home.zsh.rcInit = lib.mkAfter ''
    # Copy the most recent Codex session reply to the clipboard.
    vibe(){ tail -n2 $(ls -t ~/.codex/sessions/*/*/*/*.jsonl | head -n1) | jq -r 'select(.payload.content) |.payload.content[0].text' | kitten clipboard; }
  '';

  modules.home.unfreePackages = {
    enable = true;
    packageNames = [
      "rectangle-pro"
      "orbstack"
    ];
  };

  home.packages = with pkgs; [
    # Radically simple IT automation
    # ansible
    # Opinionated terminal GUI client
    # aerc
    # Command line tools
    # asciinema
    # A cat(1) clone with syntax highlighting and Git integration
    bat
    # The uncompromising Python code formatter
    black
    # Create and view interactive cheatsheets on the command-line
    cheat
    # Command line tool for transferring files with URL syntax
    curl
    # Replacement for 'ls' written in Rust
    eza
    # A tool to read, write and edit EXIF meta information
    exiftool
    # A simple, fast and user-friendly alternative to find
    fd
    # GNU Find Utilities, the basic directory searching utilities of the GNU operating system
    findutils
    # A command-line fuzzy finder written in Go
    fzf
    # Program for making large letters out of ordinary text
    # figlet
    # Render markdown on the CLI, with pizzazz!
    glow
    # An interactive process viewer for Linux
    htop
    # A lightweight and flexible command-line JSON processor
    jq
    # Ranger-like terminal file manager written in Rust
    joshuto
    # High-level, high-performance, dynamic language for technical computing
    # julia-bin
    # A simple terminal UI for both docker and docker-compose
    # lazydocker
    # Simple terminal UI for git commands
    # lazygit
    # A terminal file manager written in Go and heavily inspired by ranger
    lf
    # A rainbow version of cat
    clolcat
    # General-purpose media player, fork of MPlayer and mplayer2
    mpv
    # A fast, highly customizable system info script
    # neofetch
    # Review pull-requests on https://github.com/NixOS/nixpkgs
    nixpkgs-review
    # Modern shell written in Rust
    nushell
    # pandoc
    # podman
    podman-compose
    # A PDF processor written in Go
    pdfcpu
    # Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more
    # ripgrep-all
    # Intuitive find & replace CLI (sed alternative)
    sd
    # A command-line kanban board/task manager
    # taskell
    # Command to produce a depth indented directory listing
    tree
    # An archive unpacker program
    unar
    # An extraction utility for archives compressed in .zip format
    unzip
    # Tool for retrieving files using HTTP, HTTPS, and FTP
    wget
    # A linter for YAML files
    yamllint
    # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents - repo owner: kislyuk
    # yq
    # Portable command-line YAML processor - repo owner: mikefarah
    yq-go
    # jetbrains.pycharm-professional
    helix
    # Shell script analysis tool
    shellcheck
    # Tools for the google cloud platform
    gdk
    # Small and lightweight IDE
    geany
    # The GNU Image Manipulation Program
    # gimp
    # Open-source IDE for exploring and testing APIs
    bruno
    # Go Programming language
    go
  	# View colored, incremental diff in workspace or from stdin with side by side and auto pager support (Was "cdiff")
  	ydiff

    ## Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    # comma # run software from without installing it
    niv # easy dependency management for nix projects

    ## GNU/Linux Compatibility
    # GNU sed, a batch stream editor
    gnused
    # GNU implementation of the `tar' archiver
  	gnutar
  	# GNU Transport Layer Security Library
  	gnutls
  	# GNU implementation of the Awk programming language
  	gawk

    ## macOS Extensions
    # Simple clipboard manager for macOS
    maccy
    # Move and resize windows in macOS using keyboard shortcuts or snap areas
    rectangle-pro
    # Tiny menu bar calendar
	  itsycal
    # Keymap remap utilility
    karabiner-elements
  	# Windows alt-tab on macOS
  	alt-tab-macos
  	# Automatically raise and focus a window when hovering over it with the mouse
  	autoraise

    ## Python
    python313
    python313Packages.virtualenv
    python313Packages.pip
    python313Packages.pip-tools
    # A bug and style checker for Python
    python313Packages.pylint
    python313Packages.beautifulsoup4

    # ## Rust
    # cargo
    # rustc
    # rustfmt

    # ## Kubernetes
    # # Kubernetes CLI
    # krew
    # # Customization of Kubernetes YAML configurations
    # kubectl
    # # Fast way to switch between Kubernetes clusters and namespaces
    # kubectx
    # # Validate your Kubernetes configuration files
    # kubeval
    # # Package manager for kubectl plugins
    # kustomize
    # # Colorizes kubectl output
    # kubecolor
    # # A package manager for Kubernetes
    # kubernetes-helm
    # # Deploy Kubernetes Helm charts
    # helmfile
    # # CLI client for Flux, the GitOps Kubernetes operator
    # fluxctl

    # Vector graphics editor
    # inkscape-with-extensions
    # A terminal based graphical activity monitor inspired by gtop and vtop
    gotop

  	# AI Agents (urgggghh!!)
  	# Lightweight coding agent that runs in your terminal
    codex
    # AI coding agent built for the terminal
    opencode

    orbstack
    # Open source source code editor developed by Microsoft for Windows, Linux and macOS (VS Code without MS branding/telemetry/licensing)
    vscodium

    # rcat from flake
    inputs.rcat.packages.${pkgs.system}.default
  ];
}
