{ config, ... }:
{
  imports = [
    ../personal.nix
    ./backup.nix
    ./hardware-configuration.nix
    ./mounts.nix
  ];

  ## Modules
  modules = {
    theme.active = "dracula";
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
      steamcon.enable = false;
      wacom.enable = false;
    };
    shell = {
      cli.enable = true;
      devenv.enable = true;
      gnupg.enable = true;
      taskell.enable = false;
      utilities.enable = true;
    };
    services = {
      containerization.enable = true;
      adventurelog.enable = true;
      snowflake.enable = true;
      pods = {
        languagetool.enable = false;
        penpot.enable = false;
        scrutiny.enable = true;
        vaultwarden.enable = true;
      };
      adguard.enable = true;
      changedetection.enable = true;
      esphome = {
        enable = true;
        openFirewall = true;
      };
      gitea.enable = false;
      grafana.enable = false;
      home-assistant.enable = true;
      jellyfin.enable = false;
      nginx.enable = false;
      vaultwarden.enable = false;
      vpn.enable = false;
      postgresql.enable = true;
      postgresql.pgweb.enable = true;
      recipes.enable = true;
      immich.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      tailscale.enable = true;
      time-machine.enable = true;
      transmission.enable = false;
      prometheus = {
        enable = false;
        exporters = {
          node.enable = true;
          systemd.enable = true;
          statsd.enable = true;
          smartctl.enable = true;
          blackbox.enable = true;
          nginx.enable = false;
          nginxlog.enable = false;
          fail2ban.enable = false;
          adguard.enable = true;
          fritzbox.enable = false;
          postgres.enable = true;
          immich = {
            enable = true;
            envFile = "/var/secrets/immich-exporter.env";
          };
          speedtest.enable = false;
        };
        # Targets for the Prometheus Blackbox exporter
        # TODO Set targets for Uptime Kuma and Blackbox exporter
        blackboxTargets = [
          # thym.at
          "https://thym.at"
          "https://matthias.thym.at"
          "https://matthias.thym.at/de"
          "https://blog.thym.at"
          "https://nextcloud.thym.at"
          "https://cloud.thym.at"
          # nixos.at
          "https://nixos.at"
          # überwachungsbehör.de (utf-8 translated)
          "https://uptime.xn--berwachungsbehr-mtb1g.de"
          "https://grafana.xn--berwachungsbehr-mtb1g.de"
          "https://headscale.xn--berwachungsbehr-mtb1g.de"
          "https://jellyfin.xn--berwachungsbehr-mtb1g.de"
          "https://liebes.xn--berwachungsbehr-mtb1g.de"
          "https://benachrichtigungs.xn--berwachungsbehr-mtb1g.de"
          "https://prometheus.xn--berwachungsbehr-mtb1g.de"
          "https://passwort.xn--berwachungsbehr-mtb1g.de"
        ];
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

  # NixOS networking configuration
  networking = {
    networkmanager.enable = true;
    interfaces.enp9s0.wakeOnLan.enable = true;
    # Allow local network access
    # firewall.extraCommands = ''
    #   iptables -A nixos-fw -p tcp --source 192.168.8.0/24 --dport 0:9999 -j nixos-fw-accept
    #   iptables -A nixos-fw -p udp --source 192.168.8.0/24 --dport 0:9999 -j nixos-fw-accept
    # '';
  };

  virtualisation.oci-containers.containers."scrutiny".extraOptions = [
    "--device=/dev/sda"
    "--device=/dev/sdb"
    "--device=/dev/sdc"
    "--device=/dev/sdd"
    "--device=/dev/sde"
    "--device=/dev/sdf"
  ];

  # macOS Time Machine configuration
  services.netatalk.settings = {
    "Time Machine Vika" = {
      "time machine" = "yes";
      path = "/mnt/time-machine-vika";
      "valid users" = "vika";
    };
    "Time Machine Mara" = {
      "time machine" = "yes";
      path = "/mnt/time-machine-mara";
      "valid users" = "mara";
    };
  };

  boot.swraid.enable = true;


  home.file = {
    "Desktop/.use".text = "desktop";
    "Dev/.use".text = "development";
    "Downloads/.use".text = "downloads";
    "Pictures/.use".text = "photos and graphics";
    "Public/.use".text = "shared files";
    "Sync/.use".text = "synchronised files";
    "Sync/notes/.use".text = "notes";
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

    home.file = {
      "Notes/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/Sync/notes/";
      "Pictures/photos".source = config.lib.file.mkOutOfStoreSymlink "/mnt/photos/";
      "Trash/".source = config.lib.file.mkOutOfStoreSymlink "/home/mathym/.local/share/Trash/files/";
    };
  };

  sops = {
    age.keyFile = "/var/lib/sops-nix/violet.txt";
    useSystemdActivation = true;
    secrets = {
      attic-client-env = {
        sopsFile = builtins.path {
          path = ../../../secrets/violet.yaml;
          name = "violet-secrets";
        };
        format = "yaml";
        key = "ATTICD_ENV";
        path = "/etc/atticd.env";
        owner = "root";
        mode = "0400";
      };
      immich-exporter-env = {
        sopsFile = builtins.path {
          path = ../../../secrets/violet.yaml;
          name = "violet-secrets";
        };
        format = "yaml";
        key = "IMMICH_API_TOKEN";
        path = "/var/secrets/immich-exporter.env";
        owner = "root";
        group = "root";
        mode = "0400";
      };
      immich-db = {
        sopsFile = builtins.path {
          path = ../../../secrets/violet.yaml;
          name = "violet-secrets";
        };
        format = "yaml";
        key = "DB_PASSWORD";
        path = "/var/secrets/immich";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
