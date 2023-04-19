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
    ./pre-flake.nix
    # Enable this before installing with dotfiles flake
    # ../personal.nix
    # ./home.nix
  ];

  # Set stateVersion
  system.stateVersion = "22.11";

  environment.systemPackages = with pkgs; [
    # Includes commands like `vcgencmd` to measure temperature and CPU frequency
    libraspberrypi
  ];

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
}
