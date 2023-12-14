{ pkgs, ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    ./mounts.nix
    ./home.nix
  ];

  modules = {
    theme.active = "dracula";
    desktop = {
      environments = {
        bspwm.enable = false;
        hyprland.enable = true;
        lxqt.enable = false;
        plasma.enable = true;
        xfce.enable = true;
      };
      anki.enable = true;
      backup.enable = true;
      blender.enable = true;
      calibre.enable = true;
      clipboard.enable = true;
      documents.enable = true;
      flatpak.enable = true;
      fm.enable = true;
      fonts.enable = true;
      geany.enable = false;
      ghostwriter.enable = false;
      godot.enable = true;
      gpa.enable = true;
      gsmartcontrol.enable = true;
      keepassxc.enable = true;
      kvantum.enable = true;
      mail.enable = true;
      mapping.enable = true;
      nextcloud.enable = true;
      plank.enable = true;
      polish.enable = true;
      rofi.enable = true;
      screenshot.enable = true;
      thonny.enable = true;
      torrent.enable = true;
      unity.enable = true;
      vscodium.enable = true;
      browsers = {
        default = "firefox";
        chromium.enable = true;
        firefox.enable = true;
        lynx.enable = false;
        tor.enable = false;
      };
      communication = {
        delta.enable = true;
        discord.enable = true;
        jitsi.enable = true;
        matrix.enable = true;
        signal.enable = true;
        telegram.enable = true;
      };
      gaming = {
        retro.enable = true;
        steam.enable = true;
      };
      media = {
        audio.enable = true;
        daw.enable = true;
        graphics = {
          enable = true;
          raster.enable = true;
          vector.enable = true;
          photo.enable = true;
          sprites.enable = true;
        };
        kodi.enable = false;
        ncmpcpp.enable = false;
        video = {
          editing.enable = true;
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
        qemu.enable = true;
        virtualbox.enable = false;
        virt-manager.enable = true;
      };
    };
    dev = {
      cc.enable = false;
      clojure.enable = false;
      common-lisp.enable = false;
      db.enable = true;
      go.enable = false;
      java.enable = false;
      julia.enable = true;
      lua.enable = false;
      node.enable = false;
      python.enable = true;
      rust.enable = true;
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
      fancontrol.enable = false;
      image.enable = true;
      keebs.enable = true;
      mcus.enable = true;
      nvidia.enable = false;
      radeon.enable = true;
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
      devops.enable = true;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      nu.enable = true;
      pass.enable = true;
      taskell.enable = false;
      utilities.enable = true;
      zsh.enable = true;
    };
    services = {
      containerization.enable = true;
      containers = {
        snowflake.enable = false;
      };
      pods = {
        languagetool.enable = true;
        penpot.enable = false;
        scrutiny.enable = true;
        vaultwarden.enable = true;
      };
      gitea.enable = false;
      jellyfin.enable = false;
      k8s.enable = true;
      nginx.enable = false;
      vpn.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      tailscale.enable = true;
      transmission.enable = false;
    };
  };

  # NixOS program modules
  programs = {
    # Needed for some home-manager settings
    dconf.enable = true;
    kdeconnect.enable = true;
    ssh.startAgent = true;
  };

  # NixOS service configuration
  services = {
    xserver = {
      # Set eurkey as default layout
      # Optionally set more keymaps and use them with bin/keymapswitcher
      layout = "eu, at";
      # Force DPI to optimize for ultrawide screen
      # dpi = 200;
      displayManager = {
        autoLogin.enable = false;
        defaultSession = "plasma";
        # Use SDDM as display manager
        sddm = {
          enable = true;
          theme = "Dracula";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    usbutils
  ];

  # NixOS networking configuration
  networking = {
    networkmanager.enable = true;
    useDHCP = false;
  };

  # Set default monitor
  # environment.variables = rec {
  # MONITORS = ["HDMI-0" "DP-0"];
  # };
}
