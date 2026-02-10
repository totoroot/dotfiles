# Config for Raspberry Pi 3B
# Use this as /etc/nixos/configuration.nix for initial rebuild
# Board-specific installation notes can be found here:
# https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3#Board-specific_installation_notes

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./mounts.nix
    # Disable this before installing with dotfiles flake
    # ./pre-flake.nix
    # Enable this before installing with dotfiles flake
    ../personal.nix
    ./home.nix
  ];

  modules = {
    nix.atticCache = {
      enableClient = true;
      host = "purple-ts";
      port = 5129;
      # Set to your cache public key, e.g. "cache-name:BASE64"
      publicKey = null;
    };
    nix.remoteBuilder = {
      enable = true;
      host = "purple";
      user = "builder";
      systems = [ "aarch64-linux" ];
      enableCheck = true;
    };
    theme.active = "dracula";
    editors = {
      default = "micro";
      helix.enable = true;
      micro.enable = true;
      vim.enable = true;
    };
    shell = {
      aerc.enable = false;
      archive.enable = true;
      borg.enable = true;
      cli.enable = false;
      devenv.enable = false;
      devops.enable = false;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      nu.enable = true;
      pass.enable = true;
      taskell.enable = false;
      utilities.enable = true;
      zsh.enable = true;
    };
    services = {
      ssh.enable = true;
    };
  };

  # Set stateVersion
  system.stateVersion = "23.11";

  environment.systemPackages = with pkgs; [
    # Includes commands like `vcgencmd` to measure temperature and CPU frequency
    libraspberrypi
  ];

  # Basic networking
  networking = {
    hostName = "mulberry";
    extraHosts = ''
      127.0.0.1 mulberry.local
    '';
    firewall.allowedTCPPorts = [ 22 ];
  };

  # Limit update size/frequency of rebuilds
  # Also preserve space on SD card
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos.enable = false;

  # NixOS networking configuration
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
  };
}
