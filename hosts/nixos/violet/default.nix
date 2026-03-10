{ config, pkgs, ... }:
{
  imports = [
    ../personal.nix
    ./backup.nix
    ./hardware-configuration.nix
    ./mounts.nix
    ./secrets.nix
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

  users.users."matthias.thym" = {
    isNormalUser = true;
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

  environment.systemPackages = with pkgs; [
    mdadm
  ];

  # macOS Time Machine configuration
  services.netatalk.settings = {
    "Time Machine Thistle" = {
      "time machine" = "yes";
      path = "/mnt/time-machine-thistle";
      "valid users" = "mathym";
    };
    "Time Machine Work" = {
      "time machine" = "yes";
      path = "/mnt/time-machine-work";
      "valid users" = "matthias.thym";
    };
  };

  boot.swraid.enable = true;
  boot.swraid.mdadmConf = ''
    ARRAY /dev/md/0 metadata=1.2 UUID=2fe76889:ac8b610a:0fef524e:553f1eaf
  '';
  boot.kernelModules = [
    "nct6775"
  ];

  systemd.services.luks-open-quad = {
    description = "Unlock LUKS array members for quad (post-boot)";
    wantedBy = [ "multi-user.target" ];
    wants = [ "sops-install-secrets.service" ];
    after = [ "sops-install-secrets.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail
      keyfile="/run/secrets/quad-luks-key"
      if [[ ! -r "$keyfile" ]]; then
        echo "Keyfile $keyfile not found; skipping LUKS unlock."
        exit 0
      fi

      decoded_keyfile="$keyfile"
      tmp_keyfile=""
      if ${pkgs.coreutils}/bin/base64 -d "$keyfile" > /dev/null 2>&1; then
        tmp_keyfile="$(mktemp /run/quad-luks-key.XXXXXX)"
        ${pkgs.coreutils}/bin/base64 -d "$keyfile" > "$tmp_keyfile"
        chmod 0400 "$tmp_keyfile"
        decoded_keyfile="$tmp_keyfile"
      fi

      unlock() {
        local name="$1"
        local uuid="$2"
        if [[ -e "/dev/mapper/$name" ]]; then
          exit 0
        fi
        ${pkgs.cryptsetup}/bin/cryptsetup luksOpen \
          "/dev/disk/by-uuid/$uuid" "$name" --key-file "$decoded_keyfile" || true
      }

      unlock "luks-disk1" "f9c857dc-b812-47e2-ba29-57a28a54aec5"
      unlock "luks-disk2" "a3e9833a-7895-4433-829c-b8e433312174"
      unlock "luks-disk3" "cdf77a2a-f0c4-4a25-b6a2-e9b8c732c5bb"
      unlock "luks-disk4" "c0dbea84-1277-413d-81fb-78e873ec385b"

      if [[ -n "$tmp_keyfile" ]]; then
        rm -f "$tmp_keyfile"
      fi
    '';
  };

  systemd.services.mdadm-assemble-quad = {
    description = "Assemble md0 after LUKS unlock";
    wantedBy = [ "multi-user.target" ];
    after = [ "luks-open-quad.service" ];
    requires = [ "luks-open-quad.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -euo pipefail
      if [[ -e /dev/md0 ]]; then
        exit 0
      fi
      if [[ -r /proc/mdstat ]] && grep -q '^md0 ' /proc/mdstat; then
        exit 0
      fi
      for dev in /dev/mapper/luks-disk1 /dev/mapper/luks-disk2 /dev/mapper/luks-disk3 /dev/mapper/luks-disk4; do
        if [[ ! -b "$dev" ]]; then
          echo "Missing $dev; skipping mdadm assemble."
          exit 0
        fi
      done
      /run/current-system/sw/bin/mdadm --assemble /dev/md0 \
        /dev/mapper/luks-disk1 \
        /dev/mapper/luks-disk2 \
        /dev/mapper/luks-disk3 \
        /dev/mapper/luks-disk4
    '';
  };

  systemd.services.lvm-activate-quad = {
    description = "Activate LVM volumes after mdadm";
    wantedBy = [ "multi-user.target" ];
    after = [ "mdadm-assemble-quad.service" ];
    serviceConfig.Type = "oneshot";
    script = "/run/current-system/sw/bin/vgchange -ay";
  };


  ## SMB Share for Time Machine Backups ##
  services = {
    samba = {
      settings = {
        "time-machine-thisle" = {
          "path" = "/mnt/time-machine-thisle";
          "valid users" = "samba";
          "public" = "no";
          "writeable" = "yes";
          "force user" = "samba";
          # Below are the most imporant for macOS compatibility
          # Change the above to suit your needs
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
        };
        "time-machine-work" = {
          "path" = "/mnt/time-machine-work";
          "valid users" = "samba";
          "public" = "no";
          "writeable" = "yes";
          "force user" = "samba";
          # Below are the most imporant for macOS compatibility
          # Change the above to suit your needs
          "fruit:aapl" = "yes";
          "fruit:time machine" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/time-machine-thistle 0755 samba users"
    "d /mnt/time-machine-work 0755 samba users"
  ];


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

  # Allow Prometheus on jam to scrape the Home Assistant API on violet
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8123
  ];

}
