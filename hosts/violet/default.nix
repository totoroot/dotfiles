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
      steamcon.enable = false;
      wacom.enable = false;
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
        vaultwarden.enable = true;
      };
      adguard.enable = true;
      gitea.enable = false;
      grafana.enable = true;
      jellyfin.enable = true;
      k8s.enable = false;
      nginx.enable = false;
      vaultwarden.enable = false;
      vpn.enable = false;
      postgresql.enable = true;
      recipes.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
      tailscale.enable = true;
      transmission.enable = false;
      prometheus = {
        enable = true;
        exporters = {
          node.enable = true;
          systemd.enable = true;
          statsd.enable = true;
          blackbox.enable = true;
          nginx.enable = false;
          nginxlog.enable = false;
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

  virtualisation.oci-containers.containers."scrutiny".extraOptions = [
    "--device=/dev/sda"
    "--device=/dev/sdb"
    "--device=/dev/sdc"
    "--device=/dev/sdd"
    "--device=/dev/sde"
  ];

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
