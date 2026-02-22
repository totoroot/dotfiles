{ ... }:
{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    ./backup.nix
  ];

  ## Modules
  modules = {
    desktop = { };
    dev = { };
    editors = {
      default = "micro";
      vim.enable = true;
      micro.enable = true;
    };
    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      disks.enable = true;
      fancontrol.enable = true;
      keebs.enable = false;
      nvidia.enable = false;
      printers.enable = true;
      sensors.enable = true;
      wacom.enable = false;
    };
    shell = {
      aerc.enable = false;
      archive.enable = false;
      borg.enable = true;
      cli.enable = false;
      clipboard.enable = false;
      devenv.enable = false;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      pass.enable = false;
      taskell.enable = false;
      utilities.enable = true;
      zsh.enable = true;
    };
    services = {
      containers.enable = true;
      gitea.enable = false;
      jellyfin.enable = false;
      kdeconnect.enable = false;
      k8s.enable = true;
      nginx.enable = false;
      vpn.enable = true;
      ssh.enable = true;
      tor.enable = true;
      syncthing.enable = true;
      transmission.enable = false;
    };
  };

  ## Local config
  programs.ssh.startAgent = true;
  services.openssh.startWhenNeeded = true;
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false
  # here. Per-interface useDHCP will be mandatory in the future, so this
  # generated config replicates the default behaviour.
  networking.useDHCP = false;

  # Set eurkey as default layout
  # Optionally set more keymaps and use them with bin/keymapswitcher
  services.xserver.layout = "eu";


  home.file = {
    "dev/.use".text = "dev";
    "downloads/.use".text = "downloads";
    "notes/.use".text = "notes";
    "resources/.use".text = "resources";
    "shared/.use".text = "shared";
    "tmp/.use".text = "tmp";
    ".trash/.use".text = "trash";
  };

  home-manager.users.${config.user.name} = { config, ... }: {
    imports = [
      ../../../home/bridge.nix
    ];

    modules.home = {
      unfreePackages.enable = true;
      archive.enable = true;
      atuin.enable = true;
      borg.enable = true;
      duf.enable = true;
      git.enable = true;
      helix.enable = true;
      lf.enable = true;
      micro.enable = true;
      nushell.enable = true;
      sshHosts.enable = true;
      trash.enable = true;
      viddy.enable = true;
      zsh.enable = true;
    };
  };
}
