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
      datadog.enable = true;
      documents.enable = true;
      flatpak.enable = true;
      fm.enable = true;
      fonts.enable = true;
      ghostwriter.enable = false;
      godot.enable = false;
      gpa.enable = false;
      gsmartcontrol.enable = false;
      ides.enable = true;
      keepassxc.enable = false;
      kvantum.enable = false;
      mail.enable = true;
      mapping.enable = false;
      nextcloud.enable = true;
      plank.enable = false;
      polish.enable = true;
      rofi.enable = true;
      screenshot.enable = true;
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
        matrix.enable = true;
        signal.enable = true;
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
      go.enable = true;
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
      mcus.enable = false;
      nvidia.enable = false;
      radeon.enable = false;
      printers.enable = true;
      sensors.enable = true;
      steamcon.enable = false;
      wacom.enable = true;
    };
    shell = {
      aerc.enable = false;
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
      gitea.enable = false;
      jellyfin.enable = false;
      k8s.enable = true;
      nginx.enable = false;
      vpn.enable = true;
      ssh.enable = true;
      syncthing.enable = false;
      tailscale.enable = true;
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
    thermald.enable = true;
    # Enable touchpad support
    libinput.enable = true;
    displayManager = {
      # Disable autologin for increased security on portable device
      autoLogin.enable = false;
      defaultSession = "plasma";
      sddm.theme = "Dracula";
    };
    xserver = {
      # Set Austrian as default layout
      # Optionally set more keymaps and use them with bin/keymapswitcher
      xkb.layout = "at, eu";
    };
    ddccontrol.enable = true;

    # Just run `sudo ocsinventory-agent -i --nosoftware -s https://sxhw.smaxtec-animalcare.com/ocsinventory -l "" -t ""` every once in a while

    # ocsinventory-agent = {
    #   enable = true;
    #   settings = {
    #     debug = true;
    #     server = "https://sxhw.smaxtec-animalcare.com/ocsinventory";
    #     # local = "/var/lib/ocsinventory-agent/reports";
    #     ca = "/var/lib/ocsinventory-agent/cacert.pem";
    #   };
    #   interval = "monthly";
    # };
  };

  # nix.settings = {
  # cores = "";
  # max-jobs = "";
  # }

  # NixOS networking configuration
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
  };

  # Enable Gerrit Code Review locally
  # services.gerrit = {
  #   enable = true;
  #   serverId = "372e82cb-0dfa-4692-932e-cd194af9a445";
  #   listenAddress = "[::]:8020";
  #   builtinPlugins = [
  #     "codemirror-editor"
  #     "commit-message-length-validator"
  #     "delete-project"
  #     "download-commands"
  #     "gitiles"
  #     "hooks"
  #     "plugin-manager"
  #     "replication"
  #     "reviewnotes"
  #     "singleusergroup"
  #     "webhooks"
  #   ];
  # };

  user.packages = with pkgs; [
    jira-cli-go
    slack
    slack-term
    usbutils
    lshw
    inxi
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    # cloud-sql-proxy
    gcsfuse
    postgresql
    keepassxc
    meld
    delta
    # Integrated Development Environment (IDE) by Jetbrains
    jetbrains.pycharm-community-bin
    # To Do List / Time Tracker with Jira Integration
    super-productivity
  ];

  systemd.user.services."cloud-sql-proxy" = {
    description = "Starts the Google Cloud SQL Proxy";
    documentation = [
      "https://handbook.smaxtec.com/product_docu/development_docu/how_to_guides/backend/Gcloud-Kubernetes-PostgreSQL/"
      "https://cloud.google.com/sql/docs/sqlserver/connect-auth-proxy"
    ];
    # This should replace the script expression after
    # https://github.com/NixOS/nixpkgs/pull/243947
    # gets merged

    # ${pkgs.cloud-sql-proxy}/bin/cloud-sql-proxy
    script = ''
      exec /home/mathym/.nix-profile/bin/cloud-sql-proxy cloud-sql-proxy "smaxtec-system:europe-west1:smaxtecdb-postgres-11-develop-system?address=127.0.0.1&port=5433" "smaxtec-system:europe-west1:smaxtecdb-postgres-11-develop-system?address=172.17.0.1&port=5433"
    '';
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 2;
    };
  };

  # home.env = {
  # GCLOUD_PROJECT = "smaxtec-system";
  # };

  home.configFile = {
    "git/work/config".text = ''
      [core]
          sshCommand = ssh -i ~/.ssh/work -F /dev/null
      [user]
          email = matthias.thym@smaxtec.com
    '';
  };

  environment.shellAliases = {
    pycharm = "pycharm-community -Dsun.java2d.uiScale.enabled=false";
    pc = "pycharm-community -Dsun.java2d.uiScale.enabled=false";
  };

  systemd.services.nix-daemon.environment.TMPDIR = "/mnt/tmp";

  nix = {
    buildMachines = [{
      hostName = "purple";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ "big-parallel" ];
    }];
    distributedBuilds = true;
    # Optional. Useful when the builder has a faster internet connection than yours
    extraOptions = ''
      	  builders-use-substitutes = true
      	'';
  };

  environment.systemPackages = with pkgs; [
    # Create a FHS environment by command `fhs`, so we can run non-nixpkgs packages in NixOS!
    (
      let base = pkgs.appimageTools.defaultFhsEnvArgs; in
      pkgs.buildFHSEnv (base // {
        name = "fhs";
        targetPkgs = pkgs:
          # pkgs.buildFHSEnv provides just a minimal FHS environment and lacks
          # a lot of basic packages necessary for many common software
          # Add other depnedencies below if the FHS should have them already installed
          (base.targetPkgs pkgs) ++ (with pkgs; [
            pkg-config
            ncurses
          ]
          );
        profile = "export FHS=1";
        runScript = "zsh";
        extraOutputsToInstall = [ "dev" ];
      })
    )
  ];

  # Printer sharing
  # See https://nixos.wiki/wiki/Samba#Printer_sharing
  # services.samba = {
  #   enable = true;
  #   openFirewall = true;
  #   package = pkgs.samba;
  #   settings = {
  #     global = {
  #       "load printers" = "yes";
  #       "printing" = "CUPS";
  #       "printcap name" = "cups";
  #       "security" = "user";
  #     };
  #     "printers" = {
  #       "comment" = "All Printers";
  #       "path" = "/var/spool/samba";
  #       "public" = "yes";
  #       "browseable" = "yes";
  #       # to allow user 'guest account' to print.
  #       "guest ok" = "yes";
  #       "writable" = "no";
  #       "printable" = "yes";
  #       "create mode" = 0700;
  #     };
  #   };
  # };
  # systemd.tmpfiles.rules = [
  #   "d /var/spool/samba 1777 root root -"
  # ];

  # Limit update size/frequency of rebuilds
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos.enable = false;
}
