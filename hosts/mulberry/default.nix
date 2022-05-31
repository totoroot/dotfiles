{ ... }:
{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    ./home.nix
  ];

  ## Modules
  modules = {
    desktop = {
      gaming = {
        retro.enable = false;
        steam.enable = false;
      };
      bspwm.enable = true;
      documents.enable = true;
      fonts.enable = true;
      flatpak.enable = false;
      keepassxc.enable = true;
      kvantum.enable = true;
      mail.enable = true;
      screenshot.enable = true;
      fm.enable = true;
      apps = {
        anki.enable = false;
        blender.enable = false;
        calibre.enable = false;
        ide.enable = false;
        ghostwriter.enable = true;
        godot.enable = false;
        gpa.enable = false;
        gsmartcontrol.enable = false;
        nextcloud.enable = false;
        rofi.enable = true;
        torrent.enable = false;
        vscodium.enable = false;
      };
      browsers = {
        default = "firefox";
        chromium.enable = true;
        firefox.enable = true;
        lynx.enable = true;
        qutebrowser.enable = false;
        tor.enable = false;
      };
      communication = {
        delta.enable = false;
        discord.enable = false;
        jitsi.enable = true;
        matrix.enable = false;
        signal.enable = true;
        telegram.enable = true;
      };
      media = {
        audio.enable = true;
        daw.enable = false;
        graphics.enable = true;
        kodi.enable = false;
        ncmpcpp.enable = false;
        video = {
          editing.enable = false;
          player.enable = true;
          recording.enable = true;
          transcoding.enable = true;
        };
      };
      term = {
        default = "kitty";
        st.enable = true;
        kitty.enable = true;
      };
      vm = {
        qemu.enable = false;
        virtualbox.enable = false;
        virt-manager.enable = false;
      };
    };
    dev = {
      cc.enable = false;
      clojure.enable = false;
      common-lisp.enable = false;
      db.enable = false;
      go.enable = false;
      java.enable = false;
      julia.enable = true;
      lua.enable = false;
      node.enable = false;
      python.enable = true;
      rust.enable = false;
      scala.enable = false;
    };
    editors = {
      default = "micro";
      vim.enable = false;
      micro.enable = true;
    };
    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      disks.enable = true;
      fancontrol.enable = true;
      keebs.enable = true;
      nvidia.enable = false;
      printers.enable = true;
      sensors.enable = true;
      steamcon.enable = true;
      wacom.enable = true;
    };
    shell = {
      archive.enable = true;
      clipboard.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      lf.enable = true;
      aerc.enable = true;
      pass.enable = true;
      taskell.enable = true;
      zsh.enable = true;
      cli.enable = true;
    };
    services = {
      borg.enable = false;
      containers.enable = false;
      gitea.enable = false;
      jellyfin.enable	= false;
      kdeconnect.enable = true;
      k8s.enable = false;
      nginx.enable = false;
      vpn.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      transmission.enable = false;
    };
    theme.active = "quack";
  };

  ## Local config
  programs.ssh.startAgent = true;
  services.openssh.startWhenNeeded = true;
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false
  # here. Per-interface useDHCP will be mandatory in the future, so this
  # generated config replicates the default behaviour.
  networking.useDHCP = false;

  # Set Austrian as default layout
  # Optionally set more keymaps and use them with bin/keymapswitcher
  services.xserver.layout = "at";

  # Set default monitor
  environment.variables = rec {
    MAIN_MONITOR = "eDP-1";
  };
}
