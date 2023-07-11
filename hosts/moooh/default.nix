{ pkgs, ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    # ./home.nix
    ./mounts.nix
  ];

  modules = {
    theme.active = "dracula";
    desktop = {
      environments = {
        bspwm.enable = false;
        hyprland.enable = false;
        lxqt.enable = false;
        plasma.enable = true;
        xfce.enable = false;
      };
      anki.enable = false;
      backup.enable = false;
      blender.enable = false;
      calibre.enable = false;
      clipboard.enable = true;
      documents.enable = true;
      flatpak.enable = true;
      fm.enable = true;
      fonts.enable = true;
      geany.enable = true;
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
      polish.enable = true;
      rofi.enable = true;
      screenshot.enable = true;
      thonny.enable = false;
      torrent.enable = false;
      unity.enable = false;
      vscodium.enable = true;
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
        graphics = {
          enable = true;
          raster.enable = true;
          vector.enable = true;
          photo.enable = false;
          sprites.enable = false;
        };
        kodi.enable = false;
        ncmpcpp.enable = false;
        video = {
          editing.enable = false;
          player.enable = true;
          recording.enable = true;
          transcoding.enable = false;
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
      radeon.enable = false;
      printers.enable = true;
      sensors.enable = true;
      steamcon.enable = false;
      wacom.enable = true;
    };
    shell = {
      archive.enable = true;
      borg.enable = true;
      devops.enable = true;
      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      aerc.enable = false;
      pass.enable = true;
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
        vaultwarden.enable = true;
      };
      gitea.enable = false;
      jellyfin.enable = false;
      k8s.enable = false;
      nginx.enable  = false;
      vpn.enable = false;
      ssh.enable = true;
      syncthing.enable = false;
      transmission.enable = false;
    };
  };

  # NixOS program modules
  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;
    ssh.startAgent = true;
  };

  # NixOS service configuration
  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Set Austrian as default layout
      # Optionally set more keymaps and use them with bin/keymapswitcher
      layout = "at, eu";
      # Enable touchpad support
      libinput.enable = true;
      displayManager = {
        # Disable autologin for increased security on portable device
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

  # NixOS networking configuration
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
  };

  services.gerrit = {
    enable = true;
    serverId = "372e82cb-0dfa-4692-932e-cd194af9a445";
    listenAddress = "[::]:8020";
    builtinPlugins = [
      "codemirror-editor"
      "commit-message-length-validator"
      "delete-project"
      "download-commands"
      "gitiles"
      "hooks"
      "plugin-manager"
      "replication"
      "reviewnotes"
      "singleusergroup"
      "webhooks"
    ];
  };

  user.packages = with pkgs; [
    jetbrains.pycharm-community
    jira-cli-go
    slack
    slack-term
    usbutils
    lshw
    inxi
  ];

  # Limit update size/frequency of rebuilds
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos.enable = false;
}
