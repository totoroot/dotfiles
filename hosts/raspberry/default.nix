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
    theme.active = "dracula";
    editors = {
      default = "micro";
      helix.enable = true;
      micro.enable = true;
      vim.enable = true;
    };
    shell = {
      archive.enable = true;
      borg.enable = true;
      devops.enable = false;
      devenv.enable = false;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      aerc.enable = false;
      pass.enable = true;
      taskell.enable = false;
      zsh.enable = true;
      nu.enable = true;
      cli.enable = true;
    };
    services = {
      ssh.enable = true;
      clone-system-disk.enable = true;
    };
  };

  # Set stateVersion
  system.stateVersion = "22.11";

  environment.systemPackages = with pkgs; [
    # Includes commands like `vcgencmd` to measure temperature and CPU frequency
    libraspberrypi
  ];

  services = {
    home-assistant = {
      enable = true;
      configDir = "/var/lib/home-assistant";
      extraComponents = [
        esphome
        homeassistant
      ]
        };
    };

    # Basic networking
    networking = {
      hostName = "raspberry";
      extraHosts = ''
        127.0.0.1 raspberry.local
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
