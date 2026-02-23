{ config, pkgs, lib, ... }:

{
  imports = [
    ../personal.nix
    ./hardware-configuration.nix
    ./mounts.nix
    ./secrets.nix
  ];

  modules = {
    nix.atticCache = {
      enableServer = true;
      enableClient = true;
      enableWatcher = true;
      host = "localhost";
      port = 5129;
      # Set to the public key for your cache, e.g. "cache-name:BASE64"
      publicKey = "purple-cache:YdLJ8t36I3Kk7kdd6NsW84UK5bf2bDYctMuFk6d3vCw=";
      # Add ATTIC_SERVER_TOKEN_* secrets here (see attic docs)
      environmentFile = "/etc/atticd.env";
    };
    theme.active = "dracula";
    desktop = {
      environments = {
        bspwm.enable = false;
        lxqt.enable = false;
        plasma.enable = true;
        xfce.enable = false;
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
      ides.enable = true;
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
      rgb.enable = false;
      printers.enable = true;
      sensors.enable = true;
      steamcon.enable = true;
      wacom.enable = true;
    };
    shell = {
      cli.enable = true;
      devenv.enable = true;
      devops.enable = true;
      gnupg.enable = true;
      taskell.enable = false;
      utilities.enable = true;
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
      jellyfin.enable = false;
      nginx.enable = false;
      vpn.enable = true;
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
    # Needed for some home-manager settings
    dconf.enable = true;
    kdeconnect.enable = true;
    ssh.startAgent = true;
  };

  # NixOS service configuration
  services = {
    # Suspend when power button is short-pressed
    logind.settings.Login = {
      HandlePowerKey = "suspend";
    };
    xserver = {
      # Set eurkey as default layout
      # Optionally set more keymaps and use them with bin/keymapswitcher
      xkb.layout = "eu, at";
      # Force DPI to optimize for ultrawide screen
      # dpi = 200;
    };
    displayManager = {
      autoLogin.enable = false;
      defaultSession = "plasma";
      # Use SDDM as display manager
      sddm.enable = true;
    };
    resolved.enable = true;
  };

  systemd.services.ssh-suspend-inhibit = {
    description = "Block suspend while SSH sessions are active";
    wantedBy = [ "multi-user.target" ];
    after = [ "sshd.service" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      ExecStart = pkgs.writeShellScript "ssh-suspend-inhibit" ''
        set -euo pipefail

        has_ssh_session() {
          while read -r sid; do
            if ${pkgs.systemd}/bin/loginctl show-session "$sid" -p Service -p Remote | ${pkgs.gnugrep}/bin/grep -q '^Service=sshd$' && \
               ${pkgs.systemd}/bin/loginctl show-session "$sid" -p Remote | ${pkgs.gnugrep}/bin/grep -q '^Remote=yes$'; then
              return 0
            fi
          done < <(${pkgs.systemd}/bin/loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk '{print $1}')
          return 1
        }

        while true; do
          if has_ssh_session; then
            ${pkgs.systemd}/bin/systemd-inhibit --what=sleep --mode=block \
              --who=ssh-sessions --why="Active SSH session" \
              ${pkgs.coreutils}/bin/sleep 5
          else
            ${pkgs.coreutils}/bin/sleep 5
          fi
        done
      '';
    };
  };

  networking = {
    networkmanager.enable = true;
    useNetworkd = true;
    interfaces.enp7s0.wakeOnLan.enable = true;
  };

  environment.systemPackages = with pkgs; [
    usbutils
  ];

  virtualisation.oci-containers.containers."scrutiny".extraOptions = [
    "--device=/dev/nvme0n1"
    "--device=/dev/nvme1n1"
    "--device=/dev/sda"
    "--device=/dev/sdb"
  ];

  # To be able to use ttyUSB etc.
  user.extraGroups = [ "dialout" ];


  home.file = {
    "Desktop/.use".text = "desktop";
    "Development/.use".text = "development";
    "Documents/.use".text = "documents";
    "Downloads/.use".text = "downloads";
    "Games/.use".text = "games";
    # "Music/.use".text = "music";
    "Pictures/.use".text = "photos and graphics";
    "Public/.use".text = "shared files";
    "Resources/.use".text = "resources";
    "Sync/.use".text = "synchronised files";
    "Sync/notes.use".text = "notes";
    "Temp/.use".text = "temporary files";
    "Videos/.use".text = "videos";
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
      fonts.enable = true;
      git.enable = true;
      helix.enable = true;
      kitty.enable = true;
      kubernetes.enable = true;
      lf.enable = true;
      micro.enable = true;
      nushell.enable = true;
      sshHosts.enable = true;
      trash.enable = true;
      viddy.enable = true;
      zsh.enable = true;
    };

    home.file = {
      "Notes/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/Sync/notes/";
      "Trash/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/.local/share/Trash/files/";
    };
  };
}
