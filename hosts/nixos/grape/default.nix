{ config, ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    ./mounts.nix
  ];

  modules = {
    nix.secrets = {
      enable = true;
      defaultFile = "${toString ../secrets}/grape.yaml";
    };
    nix.atticCache = {
      enableClient = true;
      host = "purple-ts";
      port = 5129;
      # Set to your cache public key, e.g. "cache-name:BASE64"
      publicKey = "purple-cache:YdLJ8t36I3Kk7kdd6NsW84UK5bf2bDYctMuFk6d3vCw=";
    };
    nix.remoteBuilder = {
      enable = true;
      host = "purple";
      user = "builder";
      systems = [ "x86_64-linux" ];
      enableCheck = true;
    };
    desktop = {
      environments = {
        bspwm.enable = false;
        lxqt.enable = false;
        plasma.enable = true;
        xfce.enable = false;
      };
      anki.enable = true;
      backup.enable = true;
      blender.enable = false;
      calibre.enable = false;
      clipboard.enable = false;
      documents.enable = true;
      flatpak.enable = true;
      fm.enable = true;
      fonts.enable = true;
      ides.enable = true;
      ghostwriter.enable = false;
      handy.enable = true;
      godot.enable = false;
      gpa.enable = false;
      gsmartcontrol.enable = true;
      keepassxc.enable = false;
      kvantum.enable = false;
      mail.enable = true;
      mapping.enable = false;
      nextcloud.enable = true;
      plank.enable = false;
      polish.enable = true;
      rofi.enable = true;
      screenshot.enable = false;
      torrent.enable = true;
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
        delta.enable = true;
        discord.enable = true;
        jitsi.enable = true;
        matrix.enable = true;
        signal.enable = true;
        telegram.enable = true;
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
        qemu.enable = false;
        virtualbox.enable = false;
        virt-manager.enable = false;
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
      steamcon.enable = true;
      wacom.enable = true;
    };
    shell = {
      cli.enable = true;
      devops.enable = true;
      gnupg.enable = true;
      taskell.enable = false;
      utilities.enable = true;
    };
    services = {
      docker.enable = true;
      # Keep Docker as the single container runtime on grape.
      # Scrutiny uses the docker backend in modules/services/pods/scrutiny.nix.
      podman.enable = false;
      containers = {
        snowflake.enable = false;
      };
      pods = {
        languagetool.enable = false;
        penpot.enable = false;
        scrutiny.enable = true;
        vaultwarden.enable = false;
      };
      forgejo.enable = false;
      jellyfin.enable = false;
      nginx.enable = false;
      mullvad.enable = true;
      vpn.enable = false;
      ssh.enable = true;
      syncthing.enable = true;
      tailscale.enable = true;
      transmission.enable = false;
      prometheus = {
        enable = false;
        exporters = {
          node.enable = true;
          systemd.enable = true;
          statsd.enable = true;
          smartctl.enable = true;
        };
      };
    };
  };

  # NixOS program modules
  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;
    ssh.startAgent = true;
  };

  user.extraGroups = [ "dialout" ];

  # NixOS service configuration
  services = {
    # Enable touchpad support
    libinput.enable = true;
    displayManager = {
      # Disable autologin for increased security on portable device
      autoLogin.enable = false;
      defaultSession = "plasma";
      # Use SDDM as display manager
      sddm.enable = true;
    };
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Set Austrian as default layout
      # Optionally set more keymaps and use them with bin/keymapswitcher
      xkb.layout = "at, eu";
    };
  };

  # NixOS networking configuration
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
  };

  # Limit update size/frequency of rebuilds
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos.enable = false;

  sops.secrets.mullvad-account-number = {
    key = "MULLVAD_ACCOUNT_NUMBER";
    path = "/var/secrets/mullvad-account-number";
    owner = "root";
    group = "root";
    mode = "0400";
  };


  home.file = {
    "Development/.use".text = "development";
    "Downloads/.use".text = "downloads";
    "Notes/".source = "/home/mathym/Sync/notes/";
    "Temporary/.use".text = "temporary files";
    "Trash/".source = "/home/mathym/.local/share/Trash/files/";
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
      containers.enable = true;
      devenv.enable = true;
      duf.enable = true;
      fonts.enable = true;
      git.enable = true;
      gitlab.enable = true;
      helix.enable = true;
      lf.enable = true;
      llm.enable = true;
      micro.enable = true;
      modernShell.enable = true;
      nushell.enable = true;
      pass.enable = true;
      sops.enable = true;
      sshHosts.enable = true;
      trash.enable = true;
      viddy.enable = true;
      vim.enable = true;
      zsh.enable = true;
    };
  };
}
