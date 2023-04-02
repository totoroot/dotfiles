{ ... }:

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

  # Preserve space by sacrificing documentation and history
  documentation.nixos.enable = false;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  # Configure basic SSH access
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

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
  system.stateVersion = "22.05";

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
}
