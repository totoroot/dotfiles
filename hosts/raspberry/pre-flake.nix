# Minimal config for Raspberry Pi 3B
# These options are replaced by configuration rolled out with dotfiles flake and are no longer needed

{ pkgs, ... }:

{
  # Install some essential packages
  environment.systemPackages = with pkgs; [
    micro
    git
    bat
    helix
    gotop
  ];

  # It's what I'm used to
  programs.zsh = {
    enable = true;
    histSize = 10000;
    enableCompletion = true;
    enableBashCompletion = true;
    ohMyZsh = {
      enable = true;
      theme = "wezm";
    };
  };

  # Configure basic SSH access
  services.openssh = {
    enable = true;
    # Enable root login
    settings.PermitRootLogin = "yes";
    # Start a systemd service for each incoming SSH connection
    openssh.startWhenNeeded = true;
  };

  # Set up defaults and SSH keys for my user
  users.users.mathym = {
    isNormalUser = true;
    home = "/home/mathym";
    password = "password";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6pxS+faVh8CTTHw2ZZwnm9s54xNpDC6RJzxg43452g mathym@purple"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILplKT9yCU7in8VjPsxtxLZrhU8PajUJZascd0J4ILGv mathym@violet"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIT5s6+Feov4htIAeAuAa4VNqpXFuXVUf+jgnxQ7alqp mathym@grape"
    ];
  };

  # Users in wheel group do not need password to execute sudo
  security.sudo.wheelNeedsPassword = false;
}
