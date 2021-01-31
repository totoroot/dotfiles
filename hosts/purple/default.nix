{ ... }:
{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  modules = {
    desktop = {
      bspwm.enable		  = true;
      documents.enable 	= true;
      flatpak.enable    = true;
      keepassxc.enable 	= true;
      mail.enable      	= true;
      screenshot.enable = true;
      thunar.enable     = true;
      vscodium.enable   = true;
      apps = {
        anki.enable           = true;
        blender.enable        = true;
        calibre.enable        = true;
        evolution.enable      = true;
        ghostwriter.enable    = true;
        godot.enable          = true;
        gpa.enable            = true;
        gsmartcontrol.enable  = true;
        nextcloud.enable      = true;
        rofi.enable           = true;
        torrent.enable        = true;
      };
      browsers = {
        default			        = "firefox";
        chromium.enable 	  = false;
        firefox.enable 	    = true;
        qutebrowser.enable 	= true;
        tor.enable          = true;
      };
      communication = {
        delta.enable    = true;
        discord.enable  = true;
        jitsi.enable    = true;
        matrix.enable   = true;
        signal.enable   = true;
        telegram.enable = true;
      };
      media = {
        graphics.enable  = true;
        video.enable     = true;
        audio.enable     = true;
        daw.enable       = false;
      };
      term = {
        default      = "kitty";
        st.enable    = true;
        kitty.enable = true;
      };
      vm = {
        qemu.enable         = true;
        virtualbox.enable   = false;
        virt-manager.enable = true;
      };
    };
    dev = {
      cc.enable          = true;
      clojure.enable     = false;
      common-lisp.enable = false;
      go.enable          = true;
      julia.enable  		 = true;
      lua.enable         = false;
      node.enable        = false;
      python.enable      = true;
      rust.enable        = false;
      scala.enable       = false;
      shell.enable       = true;
    };
    editors = {
      default      = "micro";
      vim.enable   = true;
      micro.enable = true;
    };
    hardware = {
      audio.enable      = true;
      bluetooth.enable  = true;
      disks.enable      = true;
      fancontrol.enable = true;
      nvidia.enable     = true;
      sensors.enable    = true;
      wacom.enable      = true;
    };
    shell = {
      direnv.enable   = true;
      git.enable      = true;
      gnupg.enable    = true;
      pass.enable     = true;
      taskell.enable  = true;
      tmux.enable     = false;
      zsh.enable      = true;
      cli.enable      = true;
    };
    services = {
      docker.enable 		  = true;
      gitea.enable  		  = false;
      jellyfin.enable		  = false;
      k8s.enable    		  = true;
      nginx.enable			  = false;
      vpn.enable          = true;
      ssh.enable    		  = true;
      transmission.enable	= false;
    };
    theme.active = "quack";
  };

  ## Local config
  programs.ssh.startAgent           = true;
  services.openssh.startWhenNeeded  = true;
  networking.networkmanager.enable  = true;
  # The global useDHCP flag is deprecated, therefore explicitly set to false
  # here. Per-interface useDHCP will be mandatory in the future, so this
  # generated config replicates the default behaviour.
  networking.useDHCP                = false;
  # set eurkey as default layout
  # set more keymaps and use them with bin/keymapswitcher
  services.xserver.layout           = "eu";
}
