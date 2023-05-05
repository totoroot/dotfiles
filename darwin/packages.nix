{ config, mkIf, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Radically simple IT automation
    # ansible
    # Opinionated terminal GUI client
    aerc
    # Command line tools
    asciinema
    # A cat(1) clone with syntax highlighting and Git integration
    bat
    # The uncompromising Python code formatter
    black
    # Create and view interactive cheatsheets on the command-line
    cheat
    # Command line tool for transferring files with URL syntax
    curl
    # Replacement for 'ls' written in Rust
    exa
    # A tool to read, write and edit EXIF meta information
    exiftool
    # A simple, fast and user-friendly alternative to find
    fd
    # A command-line fuzzy finder written in Go
    fzf
    # Program for making large letters out of ordinary text
    figlet
    # Distributed version control system
    git
    # Linting for your git commit messages
    gitlint
    # A bash-tool to store your private data inside a git repository
    git-secret
    # Prevents you from committing secrets and credentials into git repositories
    git-secrets
    # A git pull replacement that rebases all local branches when pulling
    git-up
    # The Go Programming language
    # go
    # go_1_19
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
    lazydocker
    # Simple terminal UI for git commands
    lazygit
    # A terminal file manager written in Go and heavily inspired by ranger
    lf
    # A rainbow version of cat
    lolcat
    # Modern and intuitive terminal-based text editor
    micro
    # General-purpose media player, fork of MPlayer and mplayer2
    mpv
    # A fast, highly customizable system info script
    neofetch
    # Review pull-requests on https://github.com/NixOS/nixpkgs
    nixpkgs-review
    # Git repository summary on your terminal
    # onefetch
    pandoc
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
    # Tool for building, changing, and versioning infrastructure
    terraform
    # Magnificent app which corrects your previous console command
    thefuck
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
    # Command-line tool to download videos from YouTube.com and other sites
    youtube-dl
    # Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents - repo owner: kislyuk
    # yq
    # Portable command-line YAML processor - repo owner: mikefarah
    yq-go
    # jetbrains.pycharm-professional
    helix
    # Shell script analysis tool
    shellcheck
    # Tools for the google cloud platform
    # google-cloud-sdk

    ## Python
    python310
    python310Packages.virtualenv
    python310Packages.pip
    python310Packages.pip-tools
    # A bug and style checker for Python
    python310Packages.pylint
    python310Packages.beautifulsoup4

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
    # gotop
    # Additional completion definitions for zsh
    # zsh-completions
    zsh
  ];

  # # Create symlinks for home-manager packages in ~/Applications
  # home.activation = {
    # copyApplications = let
      # apps = pkgs.buildEnv {
        # name = "home-manager-applications";
        # paths = config.home.packages;
        # pathsToLink = "/Applications";
      # };
    # in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # baseDir="$HOME/Applications/HomeManager"
      # if [ -d "$baseDir" ]; then
        # rm -rf "$baseDir"
      # fi
      # mkdir -p "$baseDir"
      # for appFile in ${apps}/Applications/*; do
        # target="$baseDir/$(basename "$appFile")"
        # $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
        # $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
      # done
    # '';
  # };
}
