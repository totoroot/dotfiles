{ config, home-manager, pkgs, ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    ./mounts.nix
    ./home.nix
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    micro
    git
    bat
    helix
    gotop
  ];

  programs.zsh = {
    enable = true;
    histSize = 10000;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  # Configure basic SSH access
  services.openssh = {
  	enable = true;
  	settings.PermitRootLogin = "yes";
  };

  users.users.mathym = {
  	isNormalUser = true;
  	home = "/home/mathym";
  	password = "password";
  	shell = pkgs.zsh;
  	extraGroups = [ "wheel" "networkmanager" ];
  	openssh.authorizedKeys.keys = [
  		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6pxS+faVh8CTTHw2ZZwnm9s54xNpDC6RJzxg43452g mathym@purple"
  	];
  };

  # Users in wheel group do not need password to execute sudo
  security.sudo.wheelNeedsPassword = false;

  # Set stateVersion
  system.stateVersion = "22.11";

  services.avahi = {
  	enable = true;
  	publish = {
  	  enable = true;
  	  addresses	= true;
  	  workstation = true;
  	};
  };

  networking = {
  	hostName = "raspberry";
  	extraHosts = ''
  	  127.0.0.1 raspberry.local
  	'';
  	firewall.allowedTCPPorts = [ 22 80 ];
  };

  # Limit update size/frequency of rebuilds
  # Also preserve space on SD card
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos = {
  	enable = false;
  	options.allowDocBook = false;
  };

  # nix.settings.max-jobs = 4;

  home-manager.users.${config.user.name}.manual.manpages.enable = false;
}
