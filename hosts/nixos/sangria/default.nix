{ config, ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    ./mounts.nix
  ];

  modules = {
    theme.active = "dracula";
    desktop = {
      environments = {
        bspwm.enable = false;
        lxqt.enable = false;
        plasma.enable = true;
        xfce.enable = true;
      };
      anki.enable = false;
      backup.enable = false;
      blender.enable = false;
      calibre.enable = false;
      clipboard.enable = false;
      documents.enable = false;
      flatpak.enable = true;
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
      nextcloud.enable = false;
      plank.enable = false;
      polish.enable = false;
      rofi.enable = false;
      screenshot.enable = false;
      thonny.enable = false;
      torrent.enable = false;
      unity.enable = false;
      vscodium.enable = false;
      browsers = {
        default = "firefox";
        chromium.enable = true;
        firefox.enable = true;
        lynx.enable = false;
        tor.enable = false;
      };
      communication = {
        delta.enable = false;
        discord.enable = false;
        jitsi.enable = false;
        matrix.enable = false;
        signal.enable = false;
        telegram.enable = false;
      };
      gaming = {
        retro.enable = false;
        steam.enable = false;
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
      fancontrol.enable = false;
      image.enable = false;
      keebs.enable = false;
      mcus.enable = false;
      nvidia.enable = false;
      radeon.enable = false;
      printers.enable = true;
      sensors.enable = true;
      steamcon.enable = true;
      wacom.enable = false;
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
      pass.enable = false;
      taskell.enable = false;
      zsh.enable = true;
      nu.enable = true;
      cli.enable = true;
    };
    services = {
      containerization.enable = true;
      containers = {
        snowflake.enable = false;
      };
      pods = {
        languagetool.enable = false;
        penpot.enable = false;
        scrutiny.enable = true;
        vaultwarden.enable = false;
      };
      gitea.enable = false;
      jellyfin.enable = true;
      k8s.enable = false;
      nginx.enable = false;
      vpn.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      transmission.enable = false;
    };
  };

  # NixOS program modules
  programs = {
    # Needed for some home-manager settings
    dconf.enable = true;
    kdeconnect.enable = true;
    ssh.startAgent = true;
    # Manage GNOME keyring
    # seahorse.enable = true;
  };

  # NixOS service configuration
  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Set Austrian as default layout
      # Optionally set more keymaps and use them with bin/keymapswitcher
      xkb.layout = "at, eu";
      displayManager = {
        autoLogin.enable = true;
        defaultSession = "xfce";
        sddm = {
          enable = true;
          enableHidpi = false;
          theme = "breeze";
        };
      };
    };
  };

  # NixOS networking configuration
  networking = {
    networkmanager = {
      enable = true;
      wifi = {
        powersave = true;
        scanRandMacAddress = false;
      };
    };
  };

  # Limit update size/frequency of rebuilds
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos.enable = false;


  home.file = {
    "dev/.use".text = "development";
    "dls/.use".text = "downloads";
    "nts/.use".text = "notes";
    "tmp/.use".text = "temporary files";
    "trash/".source = "/home/mathym/.local/share/Trash/files/";
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
