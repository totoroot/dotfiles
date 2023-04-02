{ ... }:
{
  imports = [
    ../personal.nix
    ./backup.nix
    ./hardware-configuration.nix
    ./home.nix
    ./mounts.nix
  ];

  ## Modules
  modules = {
    desktop = {
      environments = {
        bspwm.enable = true;
        hyprland.enable = false;
        lxqt.enable = false;
        plasma.enable = true;
        xfce.enable = true;
      };
      backup.enable = true;
      clipboard.enable = true;
      documents.enable = true;
      fm.enable = true;
      fonts.enable = true;
      flatpak.enable = false;
      geany.enable = false;
      keepassxc.enable = false;
      kvantum.enable = false;
      mail.enable = true;
      plank.enable = true;
      screenshot.enable = true;
      mapping.enable = false;
      vscodium.enable = false;
      apps = {
        anki.enable = false;
        blender.enable = false;
        calibre.enable = false;
        ghostwriter.enable = false;
        godot.enable = false;
        gpa.enable = false;
        gsmartcontrol.enable = false;
        nextcloud.enable = false;
        rofi.enable = true;
        torrent.enable = false;
      };
      browsers = {
        default = "firefox";
        chromium.enable = false;
        firefox.enable = true;
        lynx.enable = true;
        tor.enable = false;
      };
      communication = {
        delta.enable = false;
        discord.enable = false;
        jitsi.enable = false;
        matrix.enable = false;
        signal.enable = true;
        telegram.enable = true;
      };
      gaming = {
        retro.enable = true;
        steam.enable = true;
      };
      media = {
        audio.enable = true;
        daw.enable = false;
        graphics.enable = true;
        kodi.enable = true;
        ncmpcpp.enable = false;
        video = {
          editing.enable = false;
          player.enable = true;
          recording.enable = false;
          transcoding.enable = false;
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
      julia.enable = false;
      lua.enable = false;
      node.enable = false;
      python.enable = false;
      rust.enable = false;
      scala.enable = false;
    };
    editors = {
      default = "hx";
      helix.enable = true;
      micro.enable = true;
      vim.enable = true;
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
      borg.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      aerc.enable = true;
      pass.enable = true;
      taskell.enable = true;
      zsh.enable = true;
      cli.enable = true;
    };
    services = {
      containerization.enable = true;
      containers = {
        snowflake.enable = true;
      };
      pods = {
        languagetool.enable = false;
        penpot.enable = false;
        scrutiny.enable = true;
        vaultwarden.enable = false;
      };
      gitea.enable = false;
      jellyfin.enable = false;
      k8s.enable = false;
      nginx.enable = false;
      vpn.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      transmission.enable = false;
    };
    theme.active = "quack-hidpi";
  };

  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;
    ssh.startAgent = true;
  };

  ## Local config
  networking.networkmanager.enable = true;
  services.openssh.startWhenNeeded = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false
  # here. Per-interface useDHCP will be mandatory in the future, so this
  # generated config replicates the default behaviour.
  networking.useDHCP = false;

  # Set eurkey as default layout
  # Optionally set more keymaps and use them with bin/keymapswitcher
  services.xserver.layout = "eu";

  # Set default monitor
  environment.variables = rec {
    MAIN_MONITOR = "HDMI-A-0";
  };

  # Scale all elemnts
  services.xserver.dpi = 100;
  # environment.variables = {
    # GDK_SCALE = "2";
    # GDK_DPI_SCALE = "0.5";
    # QT_SCALE_FACTOR = "2";
    # _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  # };

  # Auto-login user mathym
  services.xserver.displayManager.lightdm.greeters.mini.extraConfig = ''
    [SeatDefaults]
    autologin-user=mathym
  '';
}
