{ ... }:

{
  imports = [
    ./hardware-configuration.nix
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
      zsh.enable = true;
      nu.enable = false;
      cli.enable = true;
    };
    services = {
      ssh.enable = true;
    };
  };

  # Set stateVersion
  system.stateVersion = "23.11";

  # Limit update size/frequency of rebuilds
  # Also preserve space on disk
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos.enable = false;

  # NixOS networking configuration
  networking = {
    networkmanager.enable = false;
    useDHCP = false;
    interfaces."ens3" = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "93.177.65.164";
        prefixLength = 22;
      }];
      ipv6.addresses = [{
        address = "2a03:4000:38:df::";
        prefixLength = 64;
      }];
    };
    defaultGateway =
      {
        address = "93.177.64.1";
        interface = "ens3";
      };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };
}
