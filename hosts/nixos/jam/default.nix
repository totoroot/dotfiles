{ config, lib, ... }:
let
  domain = "xn--berwachungsbehr-mtb1g.de";
  gatusEndpoints = import ./gatus-endpoints.nix;
  autheliaHost = "zugangs.${domain}";
  autheliaBackend = "http://127.0.0.1:9091";
  autheliaAuthSnippet = ''
    auth_request /authelia;
    auth_request_set $user $upstream_http_remote_user;
    auth_request_set $groups $upstream_http_remote_groups;
    auth_request_set $name $upstream_http_remote_name;
    auth_request_set $email $upstream_http_remote_email;
    proxy_set_header Remote-User $user;
    proxy_set_header Remote-Groups $groups;
    proxy_set_header Remote-Name $name;
    proxy_set_header Remote-Email $email;
    error_page 401 =302 https://${autheliaHost}/?rd=$scheme://$http_host$request_uri;
  '';
  autheliaLocationSnippet = ''
    internal;
    proxy_pass ${autheliaBackend}/api/authz/auth-request;
    proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
    proxy_set_header X-Original-Method $request_method;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header Content-Length "";
    proxy_pass_request_body off;
  '';
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
      authelia = {
        enable = true;
        hostName = autheliaHost;
        legacyHostNames = [ "auth.${domain}" ];
      };
      fail2ban.enable = true;
      gatus = {
        enable = true;
        endpoints = gatusEndpoints;
      };
      headscale.enable = true;
      homepage.enable = true;
      forgejo.enable = true;
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
      uptime-kuma.enable = false;
      tailscale.enable = true;
      vaultwarden.enable = true;
      vaultwarden.databaseUrlFile = "/var/secrets/vaultwarden-db.env";
      vaultwarden.smtp = {
        host = "127.0.0.1";
        port = 25;
        security = "off";
        from = "admin@xn--berwachungsbehr-mtb1g.de";
        fromName = "Vaultwarden Admin";
        username = null;
        passwordFile = null;
      };
      grafana.enable = true;
      prometheus = {
        enable = true;
        homeAssistantApiTokenFile = "/var/secrets/prometheus-home-assistant-api.token";
        scrapeHosts = {
          node = [ "localhost" "purple-ts" "violet-ts" "grape-ts" ];
          systemd = [ "localhost" "purple-ts" "grape-ts" ];
          statsd = [ "localhost" "purple-ts" "grape-ts" ];
          smartctl = [ "purple-ts" "violet-ts" "grape-ts" ];
          nginx = [ "localhost" ];
          nginxlog = [ "localhost" ];
          fail2ban = [ "localhost" ];
          ntfy = [ "localhost" ];
          nextcloud = [ "localhost" ];
          adguard = [ "violet-ts" ];
          tailscale = [ "localhost" "purple-ts" "violet-ts" "grape-ts" ];
          speedtest = [ "localhost" "violet-ts"];
          homeAssistant = [ "violet-ts" ];
          postgres = [ "localhost" "violet-ts" ];
          endlesshGo = [ "localhost" ];
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

  services.endlessh-go = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 22;
    openFirewall = true;
    prometheus = {
      enable = true;
    };
    extraOptions = [
      "-geoip_supplier=ip-api"
    ];
  };

  services.openssh = {
    enable = true;
    ports = [ 21042 ];
    openFirewall = true;
  };


  services.prometheus.exporters.nextcloud = {
    tokenFile = "/var/secrets/nextcloud-exporter.token";
    url = "https://cloud.thym.at";
  };

  # Protect selected dashboards behind Authelia forward-auth.
  services.nginx.virtualHosts = {
    "status.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "grafana.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "prometheus.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "zugriffs.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet;
      "/ws".extraConfig = autheliaAuthSnippet;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "website.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "benachrichtigungs.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "festplatten.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };

    "anzeigen.${domain}".locations = {
      "/".extraConfig = autheliaAuthSnippet;
      "/authelia".extraConfig = autheliaLocationSnippet;
    };
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
