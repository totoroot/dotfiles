{ inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
with inputs;
{
  imports =
    # I use home-manager to deploy files to $HOME; little else
    [ home-manager.nixosModules.home-manager ]
    # All my personal modules
    ++ (mapModulesRec' (toString ./modules) import);

  # Common config for all nixos machines; and to ensure the flake operates
  # soundly
  environment.variables = {
    DOTFILES = dotFilesDir;
    # Configure nix and nixpkgs
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  nix = {
    package = pkgs.unstable.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
    nixPath = [
      "nixpkgs=${nixos}"
      "nixpkgs-unstable=${nixos-unstable}"
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
      nixpkgs.flake = nixos-unstable;
    };
    # useSandbox = true;
  };

  system.configurationRevision = mkIf (self ? rev) self.rev;
  system.stateVersion = mkDefault "22.11";

  ## Some reasonable, global defaults
  # This is here to appease 'nix flake check' for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  # Use the latest kernel by default
  boot.kernelPackages = mkDefault pkgs.unstable.linuxPackages_latest;

  boot.loader = {
    systemd-boot = {
      enable = mkDefault true;
      configurationLimit = mkDefault 10;
    };
    efi = {
      canTouchEfiVariables = mkDefault true;
    };
  };

  # Suspend when power button is short-pressed
  services.logind.extraConfig = mkDefault ''
    HandlePowerKey=suspend
  '';

  # Take out the garbage every once in a while
  nix.gc = {
    automatic = mkDefault true;
    dates = mkDefault "weekly";
    options = mkDefault "--delete-older-than 30d";
  };

  # Do not start a sulogin shell if mounting a filesystem fails
  systemd.enableEmergencyMode = mkDefault false;

  security.polkit = {
    enable = true;
    adminIdentities = [
      "unix-group:wheel"
      "unix-group:admin"
    ];
  };

  # Just the bear necessities...
  environment.systemPackages = with pkgs; [
    unstable.cached-nix-shell
    coreutils
    git
    vim
    micro
    curl
    wget
    gnumake
    unzip
  ];
}
