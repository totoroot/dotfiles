{ inputs, lib, pkgs, ... }:

with lib;
with lib.my;
with inputs;
{
  imports =
    # I use home-manager to deploy files to $HOME; little else
    [ home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
    ]
    # All my personal modules
    ++ (mapModulesRec' (toString ./modules) import);

  # Common config for all NixOS machines; and to ensure the flake operates
  # soundly
  environment.variables = {
    DOTFILES = dotFilesDir;
    # Configure nix and nixpkgs
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    extraOptions = "experimental-features = nix-command flakes";
    nixPath = [
      "nixpkgs=${nixos}"
      "nixpkgs-overlays=${dotFilesDir}/overlays"
      "home-manager=${home-manager}"
      "dotfiles=${dotFilesDir}"
    ];
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    registry = {
      nixos.flake = nixos;
    };
    # Take out the garbage every once in a while
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-than 30d";
    };
    # useSandbox = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena;
    })
  ];

  system = {
    stateVersion = mkDefault "23.05";
    configurationRevision = mkIf (self ? rev) self.rev;
    # Present information of what is being updated on nixos-rebuild
    activationScripts = {
      diff = {
        supportsDryActivation = true;
        # text = ''
        # if [[ -e /run/current-system ]]; then
        # ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
        # fi
        # '';
        text = ''
          if [[ -e /run/current-system ]]; then
            echo -e "\e[36mPackage version diffs:\e[0m"
            ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
          fi
        '';
      };
      needsreboot = {
        supportsDryActivation = true;
        text = ''
          if [[ -e /run/current-system ]]; then
            echo -e "\e[36mSystem changes requiring a reboot:\e[0m"
            /run/current-system/sw/bin/nixos-needsreboot
          fi
        '';
      };
    };
  };

  ## Some reasonable, global defaults
  # This is here to appease 'nix flake check' for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  boot = {
    # Use the latest kernel by default
    kernelPackages = mkDefault pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = mkDefault true;
        configurationLimit = mkDefault 10;
        consoleMode = mkDefault "auto";
      };
      efi.canTouchEfiVariables = mkDefault true;
    };
  };

  # Let's you run AppImages directly binfmt and appimage-run
  # Available since NixOS 24.05
  # See https://nixos.wiki/wiki/Appimage for more information
  programs.appimage.binfmt = true;

  services = {
    # Start a systemd service for each incoming SSH connection
    openssh.startWhenNeeded = mkDefault true;
    # Enable periodic SSD TRIM to extend life of mounted SSDs
    fstrim.enable = mkDefault true;
  };

  # Do not start a sulogin shell if mounting a filesystem fails
  systemd.enableEmergencyMode = mkDefault false;

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  security.polkit = {
    enable = true;
    adminIdentities = [
      "unix-group:wheel"
      "unix-group:admin"
    ];
  };

  # Just the bear necessities...
  environment.systemPackages = with pkgs; [
    cached-nix-shell
    coreutils
    git
    micro
    curl
    wget
    gnumake
    unzip
    # Needed for alternative diff activationScript
    nvd
    inputs.nixos-needsreboot.packages.${system}.default
  ];
}
