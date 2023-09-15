{ inputs, lib, pkgs, ... }:

with lib;
with lib.my;
with inputs;
{
  imports =
    # I use home-manager to deploy files to $HOME; little else
    [ home-manager.nixosModules.home-manager ]
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
    package = pkgs.nixVersions.stable;
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
      nixpkgs.flake = nixpkgs;
    };
    # Take out the garbage every once in a while
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-than 30d";
    };
    # useSandbox = true;
  };

  system = {
    stateVersion = mkDefault "23.05";
    configurationRevision = mkIf (self ? rev) self.rev;
    # Present information of what is being updated on nixos-rebuild
    activationScripts.diff = {
      supportsDryActivation = true;
      # text = ''
      # if [[ -e /run/current-system ]]; then
      # ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
      # fi
      # '';
      text = ''
        if [[ -e /run/current-system ]]; then
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        fi
      '';
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
      };
      efi.canTouchEfiVariables = mkDefault true;
    };
  };

  services = {
    # Start a systemd service for each incoming SSH connection
    openssh.startWhenNeeded = mkDefault true;
    # Enable periodic SSD TRIM to extend life of mounted SSDs
    fstrim.enable = mkDefault true;
    # Suspend when power button is short-pressed
    logind.extraConfig = mkDefault ''
      HandlePowerKey=suspend
    '';
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
  ];
}
