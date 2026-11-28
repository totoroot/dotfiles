{ config, lib, pkgs, ... }:
let
  domain = "xn--berwachungsbehr-mtb1g.de";
  monitoringTargets = import ./monitoring-targets.nix;
  gatusEndpoints = lib.filter (t: t.gatus or false) monitoringTargets;
  blackboxTargets = map (t: t.url) (lib.filter (t: t.blackbox or false) monitoringTargets);
  certificateAlertTargets = map (t: t.url) (lib.filter (t: t.certificate or false) monitoringTargets);
  autheliaHost = "zugangs.${domain}";
  thymITAutheliaHost = "login.thym.it";
in
{
  imports = [
    ./hardware-configuration.nix
    ./mounts.nix
    ./backups.nix
    (import ./nginx.nix { inherit domain autheliaHost thymITAutheliaHost; })
    ./mail-queue-metrics.nix
    ./secrets.nix
  ];

  modules = {
    nix = {
      secrets.enable = true;
      atticCache = {
        enableClient = true;
        host = "purple-ts";
        port = 5129;
        # Use purple's stable Tailscale IP; jam's resolv.conf uses upstream DNS.
        substituterUrl = "http://100.64.0.2:5129/purple-cache";
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
      remoteBuilderServer = {
        enable = true;
        authorizedKeys = [
          "restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgUeIeU7yj63m+YWbrtYmV1oBqDlj038tUJu7faCDPj nix-builder@ATGRZMBP43"
        ];
      };
    };
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
        additionalPortals = [
          {
            hostName = thymITAutheliaHost;
            cookieDomain = "thym.it";
          }
        ];
      };
      fail2ban.enable = true;
      gatus = {
        enable = true;
        endpoints = gatusEndpoints;
      };
      headscale.enable = true;
      homepage.enable = true;
      loki.enable = true;
      alloy.enable = true;
      forgejo.enable = false;
      forgejo-runner.enable = false;
      gitlab-runner.enable = true;
      nextcloud.enable = true;
      mailserver.enable = true;
      nginx.enable = true;
      docker.enable = true;
      podman.enable = true;
      email-backend = {
        enable = true;
        sender = "admin@thym.it";
        allowedOrigins = [
          "https://geburtstags.${domain}"
          "https://grueneis-psychologie.at"
          "https://thym.it"
          "https://draft.thym.it"
        ];
        smtp = {
          host = "127.0.0.1";
          port = 25;
          starttls = false;
          username = null;
          passwordFile = null;
        };
        routes = {
          rsvp = {
            recipient = "admin@thym.it";
            sender = "admin@thym.it";
            languageMode = "fixed";
            language = "en";
            requireSharedSecret = true;
            sharedSecretFile = "/var/secrets/rsvp-invite-code";
            subject = "RSVP submission";
            subjects = {
              de = "Neue Antwort auf Einladung";
              en = "New RSVP submission";
            };
            templateFiles = {
          de = "/var/www/geburtstags.xn--berwachungsbehr-mtb1g.de/mail-templates/rsvp.de.txt";
          en = "/var/www/geburtstags.xn--berwachungsbehr-mtb1g.de/mail-templates/rsvp.en.txt";
            };
            requiredFields = [ "name" "email" "attendance" ];
          };
          rsvp-confirmation = {
            recipient = "";
            recipientFromField = "email";
            sender = "admin@thym.it";
            languageMode = "payload";
            requireSharedSecret = true;
            sharedSecretFile = "/var/secrets/rsvp-invite-code";
            subject = "Danke für deine Antwort auf die Einladung";
            subjects = {
              de = "Danke für deine Antwort auf die Einladung";
              en = "Thanks for your RSVP";
            };
            templateFiles = {
          de = "/var/www/geburtstags.xn--berwachungsbehr-mtb1g.de/mail-templates/rsvp-confirmation.de.txt";
          en = "/var/www/geburtstags.xn--berwachungsbehr-mtb1g.de/mail-templates/rsvp-confirmation.en.txt";
            };
            icsFile = "/var/www/geburtstags.xn--berwachungsbehr-mtb1g.de/mail-assets/event.ics";
            requiredFields = [ "name" "email" "attendance" ];
          };
          kontakt = {
            recipient = "praxis@grueneis-psychologie.at";
            sender = "praxis@grueneis-psychologie.at";
            subject = "Praxis Kontaktformular";
            subjects = {
              de = "Neue Anfrage über das Kontaktformular";
              en = "New contact form inquiry";
            };
            templateFiles = {
              de = "/var/www/grueneis-psychologie.at/mail-templates/kontakt.de.txt";
              en = "/var/www/grueneis-psychologie.at/mail-templates/kontakt.en.txt";
            };
            requiredFields = [ "name" "email" "inquiry" ];
          };
          thymit-contact = {
            recipient = "hello@thym.it";
            sender = "hello@thym.it";
            subject = "thym.IT contact form";
            subjects = {
              de = "Neue Anfrage über das Kontaktformular";
              en = "New contact form inquiry";
            };
            templateFiles = {
              de = "/var/www/thym.it/mail-templates/contact.de.txt";
              en = "/var/www/thym.it/mail-templates/contact.en.txt";
            };
            requiredFields = [ "email" "subject" "message" ];
          };
          thymit-contact-confirmation = {
            recipient = "";
            recipientFromField = "email";
            sender = "hello@thym.it";
            subject = "Thank you for your inquiry";
            subjects = {
              de = "Vielen Dank für deine Anfrage";
              en = "Thank you for your inquiry";
            };
            templateFiles = {
              de = "/var/www/thym.it/mail-templates/contact-confirmation.de.txt";
              en = "/var/www/thym.it/mail-templates/contact-confirmation.en.txt";
            };
            requiredFields = [ "email" "subject" "message" ];
          };
        };
      };
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
      ntfy = {
        enable = true;
        hostName = "ntfy.thym.it";
      };
      plausible.enable = true;
      ssh.enable = true;
      uptime-kuma.enable = false;
      tailscale.enable = true;
      vaultwarden.enable = true;
      vaultwarden.databaseUrlFile = "/var/secrets/vaultwarden-db.env";
      vaultwarden.smtp = {
        host = "127.0.0.1";
        port = 25;
        security = "off";
        from = "admin@thym.it";
        fromName = "Vaultwarden Admin";
        username = null;
        passwordFile = null;
      };
      grafana.enable = true;
      prometheus = {
        enable = true;
        homeAssistantApiTokenFile = "/var/secrets/prometheus-home-assistant-api.token";
        inherit blackboxTargets certificateAlertTargets;
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
          gitlabRunner = [ "localhost" ];
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
      rustypaste = {
        enable = false;
        serverHost = "bin.thym.it";
      };
      privatebin = {
        enable = false;
        serverHost = "daten.${domain}";
      };
      wichtelwerkstatt = {
        enable = true;
        sendMail = true;
      };
      windshift = {
        enable = true;
        baseUrl = "https://delivery.thym.it";
        environmentFile = config.sops.secrets.windshift-env.path;
        settings = {
          USE_PROXY = true;
          LOG_FORMAT = "json";
          POSTGRES_CONNECTION_STRING = "postgresql:///windshift?host=/run/postgresql";
        };
      };
    };
  };

  services.postgresql = {
    # Preserve Spliit's database and role independently of the paused service.
    ensureDatabases = lib.mkAfter [ "windshift" "spliit" ];
    ensureUsers = lib.mkAfter [
      {
        name = "windshift";
        ensureDBOwnership = true;
      }
      {
        name = "spliit";
        ensureDBOwnership = true;
      }
    ];
  };

  # Expose the dashboard only through the Authelia-protected virtual host.
  services.changedetection-io = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 5002;
    behindProxy = true;
    baseURL = "https://website.${domain}";
  };

  mailserver.accounts."mail-canary@thym.it".hashedPasswordFile =
    config.sops.secrets.mail-canary-password-hash.path;

  services.ntfy-sh = {
    environmentFile = config.sops.secrets.ntfy-auth-env.path;
    settings.auth-access = [
      "mathym-desktop:jam-backups:ro"
      "mathym-desktop:uptime-alerts:ro"
      "mathym-phone:jam-backups:ro"
      "mathym-phone:uptime-alerts:ro"
      "jam-backup-publisher:jam-backups:wo"
      "mathym-desktop:change-alerts:ro"
      "mathym-phone:change-alerts:ro"
      "jam-change-publisher:change-alerts:wo"
    ];
  };

  systemd.services.ntfy-sh = {
    requires = [ "sops-install-secrets.service" ];
    after = [ "sops-install-secrets.service" ];
  };

  services.gitlab-runner = lib.mkIf config.modules.services.gitlab-runner.enable {
    settings.concurrent = 3;
    settings.listen_address = "127.0.0.1:9252";
    services = {
      # Prepared declaratively; module toggle keeps runner disabled until rollout.
      default = {
        authenticationTokenConfigFile = "/var/secrets/gitlab-runner-default-token.env";
        dockerImage = "debian:stable";
        dockerDisableCache = true;
        requestConcurrency = 2;
        registrationFlags = [ "--shell" "bash" ];
      };

      nix = {
        authenticationTokenConfigFile = "/var/secrets/gitlab-runner-nix-token.env";
        dockerImage = "alpine:3.22";
        dockerDisableCache = true;
        requestConcurrency = 2;
        registrationFlags = [ "--shell" "bash" ];
        dockerVolumes = [
          "/nix/store:/nix/store:ro"
          "/nix/var/nix/db:/nix/var/nix/db:ro"
          "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        ];
        environmentVariables = {
          NIX_REMOTE = "daemon";
        };
      };
    };
  };

  systemd.services.gitlab-runner = lib.mkIf config.modules.services.gitlab-runner.enable {
    wants = [ "docker.service" ];
    after = [ "docker.service" ];
    environment = {
      HOME = "/var/lib/gitlab-runner";
      XDG_RUNTIME_DIR = "/run/gitlab-runner";
    };
    serviceConfig = {
      RuntimeDirectory = "gitlab-runner";
      RuntimeDirectoryMode = "0700";
      SupplementaryGroups = [ "docker" ];
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

  services.spliit = {
    # Paused while expenses use Nextcloud Cospend. Keep configuration for later.
    enable = false;
    openFirewall = false;
    settings = {
      PORT = 3011;
      NEXT_PUBLIC_BASE_URL = "https://ausgaben.xn--berwachungsbehr-mtb1g.de";
      NEXT_PUBLIC_DEFAULT_CURRENCY_CODE = "EUR";
      NEXT_PUBLIC_ENABLE_EXPENSE_DOCUMENTS = false;
      NEXT_PUBLIC_ENABLE_RECEIPT_EXTRACT = false;
      NEXT_PUBLIC_ENABLE_CATEGORY_EXTRACT = false;
    };
    database = {
      createLocally = true;
      name = "spliit";
      user = "spliit";
    };
  };


  services.prometheus.exporters.nextcloud = {
    tokenFile = "/var/secrets/nextcloud-exporter.token";
    url = "https://cloud.thym.at";
  };

  # Defense in depth after the November 2026 nginx2root disclosure:
  # https://xint.io/blog/nginx2root-remote-code-execution
  # The nginx update closes the reported web entry point, but it does not fix
  # the separate Linux SCTP privilege escalation. Jam's running kernel (7.0.5
  # when checked) shipped SCTP as a loadable module. It was not loaded, but
  # modprobe would load it on demand. No SCTP consumers are declared on jam.
  # Deny modprobe loads rather than just suppressing alias-based autoloading.
  # This does not unload an existing module or cover built-in SCTP. Revisit
  # once the deployed kernel is confirmed fixed or a service needs SCTP.
  boot.extraModprobeConfig = ''
    install sctp ${pkgs.coreutils}/bin/false
  '';

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
  users.users.${config.user.name}.extraGroups = [ "docker" ];

  users.groups.deploy-web = { };
  users.users.deploy-web = {
    isSystemUser = true;
    uid = 5005;
    group = "deploy-web";
    home = "/var/www";
    createHome = false;
    useDefaultShell = true;
  };

  # Consolidated static-site deployment ownership (replaces per-site users like blog/praxis).
  systemd.tmpfiles.rules = [
    "d /var/www/assets.thym.it 0755 deploy-web deploy-web -"
    "d /var/www/ausm-keller.at 0755 deploy-web deploy-web -"
    "d /var/www/blog.thym.at 0755 deploy-web deploy-web -"
    "d /var/www/thym.it 0755 deploy-web deploy-web -"
    "d /var/www/grueneis-psychologie.at 0755 deploy-web deploy-web -"
    "d /var/www/matthias.thym.at 0755 deploy-web deploy-web -"
    "d /var/www/theaterschaffen.de 0755 deploy-web deploy-web -"
    "d /var/www/die.theaterschaffen.de 0755 deploy-web deploy-web -"
    "d /var/www/wichteln.thym.it 0755 deploy-web deploy-web -"
    "d /var/www/nixos.at 0755 deploy-web deploy-web -"
    "d /var/www/thym.at 0755 deploy-web deploy-web -"
    "d /var/www/womanma.de 0755 deploy-web deploy-web -"
    "d /var/www/kuh.xn--berwachungsbehr-mtb1g.de 0755 deploy-web deploy-web -"
  ];


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
