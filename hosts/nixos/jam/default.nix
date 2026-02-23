{ config, lib, ... }:
let
  domain = "xn--berwachungsbehr-mtb1g.de";
in
{
  imports = [
    ./hardware-configuration.nix
    ./mounts.nix
    ./secrets.nix
  ];

  modules = {
    nix = {
      secrets.enable = true;
      atticCache = {
        enableClient = true;
        host = "purple-ts";
        port = 5129;
        # Set to your cache public key, e.g. "cache-name:BASE64"
        publicKey = "purple-cache:YdLJ8t36I3Kk7kdd6NsW84UK5bf2bDYctMuFk6d3vCw=";
        environmentFile = "/etc/atticd.env";
      };
      remoteBuilder = {
        enable = true;
        host = "purple";
        user = "builder";
        systems = [ "x86_64-linux" ];
        enableCheck = true;
      };
    };
    theme.active = "dracula";
    editors = {
      default = "micro";
      vim.enable = true;
    };
    shell = {
      utilities.enable = true;
    };
    services = {
      fail2ban.enable = true;
      headscale.enable = true;
      homepage.enable = true;
      nextcloud.enable = true;
      mailserver.enable = true;
      nginx.enable = true;
      goaccess = {
        enable = true;
        logFilePath = "/var/log/nginx/access.log";
        logFileFormat = "COMBINED";
        enableNginx = true;
        nginxEnableSSL = true;
        serverHost = "zugriffs.${domain}";
        serverPath = "";
        userName = "goaccess";
      };
      ntfy.enable = true;
      plausible.enable = false;
      ssh.enable = true;
      uptime-kuma.enable = true;
      tailscale.enable = true;
      vaultwarden.enable = true;
      grafana.enable = true;
      prometheus = {
        enable = true;
        homeAssistantApiTokenFile = "/var/secrets/prometheus-home-assistant-api.token";
        scrapeHosts = {
          node = [ "jam" "purple-ts" "violet-ts" "grape-ts" ];
          systemd = [ "jam" "purple-ts" "grape-ts" ];
          statsd = [ "jam" "purple-ts" "grape-ts" ];
          smartctl = [ "purple-ts" "violet-ts" "grape-ts" ];
          nginx = [ "jam" ];
          nginxlog = [ "jam" ];
          fail2ban = [ "jam" ];
          ntfy = [ "jam" ];
          nextcloud = [ "jam" ];
          adguard = [ "violet-ts" ];
          tailscale = [ "jam" "purple-ts" "violet-ts" "grape-ts" ];
          speedtest = [ "jam" "violet-ts"];
          homeAssistant = [ "violet-ts" ];
          postgres = [ "jam" "violet-ts" ];
          immich = [ "violet-ts" ];
        };
        exporters = {
          node.enable = true;
          systemd.enable = true;
          statsd.enable = true;
          blackbox.enable = true;
          nextcloud.enable = true;
          nginx.enable = true;
          nginxlog.enable = true;
          fail2ban.enable = true;
          postgres.enable = true;
          speedtest.enable = false;
        };
      };
      webmail.enable = true;
      wordpress.enable = false;
    };
  };


  services.prometheus.exporters.nextcloud = {
    tokenFile = "/var/secrets/nextcloud-exporter.token";
    url = "https:/cloud.thym.at";
  };

  # Set stateVersion
  system.stateVersion = "25.11";

  # Limit update size/frequency of rebuilds
  # Also preserve space on disk
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos.enable = false;

  # NixOS networking configuration
  networking = {
    networkmanager.enable = false;
    useDHCP = true;
    interfaces."ens3" = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "45.83.104.124";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2a03:4000:46:a49::";
        prefixLength = 64;
      }];
    };
    defaultGateway =
      {
        address = "45.83.104.1";
        interface = "ens3";
      };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    nameservers = [
      "9.9.9.9"
    ];
  };

  users.users.goaccess.extraGroups = [ "nginx" ];


  home-manager.users.${config.user.name} = { config, ... }: {
    imports = [
      ../../../home/bridge.nix
    ];

    modules.home = {
      unfreePackages.enable = true;
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
