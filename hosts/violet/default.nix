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
    theme.active = "dracula";
    desktop = {
      environments = {
        bspwm.enable = false;
        hyprland.enable = false;
        lxqt.enable = false;
        plasma.enable = false;
        xfce.enable = false;
      };
      anki.enable = false;
      backup.enable = true;
      blender.enable = false;
      calibre.enable = false;
      clipboard.enable = true;
      documents.enable = true;
      flatpak.enable = false;
      fm.enable = true;
      fonts.enable = true;
      geany.enable = false;
      ghostwriter.enable = false;
      godot.enable = false;
      gpa.enable = false;
      gsmartcontrol.enable = false;
      keepassxc.enable = false;
      kvantum.enable = false;
      mail.enable = true;
      mapping.enable = false;
      nextcloud.enable = true;
      plank.enable = true;
      polish.enable = true;
      rofi.enable = true;
      screenshot.enable = true;
      torrent.enable = false;
      unity.enable = false;
      vscodium.enable = false;
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
      default = "micro";
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
      aerc.enable = true;
      archive.enable = true;
      borg.enable = true;
      cli.enable = true;
      devenv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      pass.enable = true;
      taskell.enable = false;
      utilities.enable = true;
      zsh.enable = true;
    };
    services = {
      containerization.enable = true;
      snowflake.enable = true;
      pods = {
        home-assistant.enable = true;
        languagetool.enable = false;
        penpot.enable = false;
        scrutiny.enable = true;
      };
      gitea.enable = false;
      grafana.enable = true;
      jellyfin.enable = true;
      k8s.enable = false;
      nginx.enable = false;
      vaultwarden.enable = true;
      vpn.enable = false;
      postgresql.enable = true;
      recipes.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      tailscale.enable = true;
      transmission.enable = false;
    };
  };

  system.stateVersion = "23.11";

  # NixOS program modules
  programs = {
    # Needed for some home-manager settings
    dconf.enable = true;
    kdeconnect.enable = true;
    ssh.startAgent = true;
  };

  # NixOS networking configuration
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
    # Allow local network access
    # firewall.extraCommands = ''
    #   iptables -A nixos-fw -p tcp --source 192.168.8.0/24 --dport 0:9999 -j nixos-fw-accept
    #   iptables -A nixos-fw -p udp --source 192.168.8.0/24 --dport 0:9999 -j nixos-fw-accept
    # '';
  };

  #   # NixOS service configuration
  #   services = {
  #     xserver = {
  #       # Set eurkey as default layout
  #       # Optionally set more keymaps and use them with bin/keymapswitcher
  #       layout = "eu, at";
  #       # Force DPI to optimize for ultrawide screen
  #       # dpi = 200;
  #       displayManager = {
  #         autoLogin.enable = true;
  #         defaultSession = "plasma";
  #         # Use SDDM as display manager
  #         sddm = {
  #           enable = true;
  #           theme = "Dracula";
  #         };
  #       };
  #     };
  #   };
  #
  #   # Set default monitor
  #   environment.variables = rec {
  #   MAIN_MONITOR = "HDMI-A-0";
  #   };
  #
  #   environment.variables = {
  #     GDK_SCALE = "2";
  #     GDK_DPI_SCALE = "0.5";
  #     QT_SCALE_FACTOR = "2";
  #     _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  #   };
}
