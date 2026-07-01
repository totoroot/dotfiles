{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.nextcloud;
  domain = "thym.at";
  adminEmail = "admin@thym.it";
  nextcloudPackage = pkgs.nextcloud33;
  baseAppNames = [
    "bookmarks"
    "calendar"
    # "contacts"
    # "cookbook"
    # "cospend"
    "deck"
    # "files_automatedtagging"
    "forms"
    # "groupfolders"
    "mail"
    # "music"
    "news"
    "notes"
    "onlyoffice"
    # "polls"
    "qownnotesapi"
    # "richdocuments"
    # "tasks"
    # "whiteboard"
  ];
  optionalAppNames = lib.optionals (lib.versionOlder nextcloudPackage.version "33") [ "memories" ];
  selectedAppNames = baseAppNames ++ optionalAppNames;
  nc4nixApps = {
    bookmarks = pkgs.fetchNextcloudApp {
      name = "bookmarks";
      appName = "bookmarks";
      appVersion = "16.2.2";
      hash = "sha256-8F+sNG/+M8Ed/q5dcxW95KS5ZBNsEeZNR0P2OIe/HqQ=";
      url = "https://github.com/nextcloud/bookmarks/releases/download/v16.2.2/bookmarks-16.2.2.tar.gz";
      license = "agpl3Plus";
    };
    calendar = pkgs.fetchNextcloudApp {
      name = "calendar";
      appName = "calendar";
      appVersion = "6.5.0";
      hash = "sha256-k7A38geyX6PS2j2t5iIXMMZMJsPKIiySVRKxcPAj+pM=";
      url = "https://github.com/nextcloud-releases/calendar/releases/download/v6.5.0/calendar-v6.5.0.tar.gz";
      license = "agpl3Plus";
    };
    contacts = pkgs.fetchNextcloudApp {
      name = "contacts";
      appName = "contacts";
      appVersion = "8.7.2";
      hash = "sha256-L0ro4VoU1GDMcs1m7qGns+S8y5+n1Q0oQ5EO1ojdLr0=";
      url = "https://github.com/nextcloud-releases/contacts/releases/download/v8.7.2/contacts-v8.7.2.tar.gz";
      license = "agpl3Plus";
    };
    cookbook = pkgs.fetchNextcloudApp {
      name = "cookbook";
      appName = "cookbook";
      appVersion = "0.11.7";
      hash = "sha256-Xn2yvgVL7XPIN8awCaH5mznRMW9Jcr0s2E19D13Hm8I=";
      url = "https://github.com/christianlupus-nextcloud/cookbook-releases/releases/download/v0.11.7/cookbook-0.11.7.tar.gz";
      license = "agpl3Plus";
    };
    cospend = pkgs.fetchNextcloudApp {
      name = "cospend";
      appName = "cospend";
      appVersion = "4.0.2";
      hash = "sha256-3uphQHtKlW8kXeLA5hMDpT14lEf+tnJyy4hfKioBDSw=";
      url = "https://github.com/julien-nc/cospend-nc/releases/download/v4.0.2/cospend-4.0.2.tar.gz";
      license = "agpl3Plus";
    };
    deck = pkgs.fetchNextcloudApp {
      name = "deck";
      appName = "deck";
      appVersion = "1.17.4";
      hash = "sha256-DVSFbea5d0CL3bdpO8iOBYXKHSbXCQ8oLHi5YkPbCI4=";
      url = "https://github.com/nextcloud-releases/deck/releases/download/v1.17.4/deck-v1.17.4.tar.gz";
      license = "agpl3Plus";
    };
    files_automatedtagging = pkgs.fetchNextcloudApp {
      name = "files_automatedtagging";
      appName = "files_automatedtagging";
      appVersion = "4.0.0";
      hash = "sha256-A9cjrz0sJKMA+LinBiyUWJ5UOgvyfiJ3dLLP2NKBy50=";
      url = "https://github.com/nextcloud-releases/files_automatedtagging/releases/download/v4.0.0/files_automatedtagging-v4.0.0.tar.gz";
      license = "agpl3Plus";
    };
    forms = pkgs.fetchNextcloudApp {
      name = "forms";
      appName = "forms";
      appVersion = "5.3.2";
      hash = "sha256-r570gxd4j/AEMzT3vul6qxJsJ/bTEW459LONUOYA8ZM=";
      url = "https://github.com/nextcloud-releases/forms/releases/download/v5.3.2/forms-v5.3.2.tar.gz";
      license = "agpl3Plus";
    };
    groupfolders = pkgs.fetchNextcloudApp {
      name = "groupfolders";
      appName = "groupfolders";
      appVersion = "21.0.8";
      hash = "sha256-2jy9p4pu2OXdi8JENFCBcPSDHnGIQkpzuyKkjxALAE4=";
      url = "https://github.com/nextcloud-releases/groupfolders/releases/download/v21.0.8/groupfolders-v21.0.8.tar.gz";
      license = "agpl3Plus";
    };
    mail = pkgs.fetchNextcloudApp {
      name = "mail";
      appName = "mail";
      appVersion = "5.10.4";
      hash = "sha256-tB6gzD9LfVFT9PilCO3/6+/Oj2z+cBRpYlDcvlD/Wm4=";
      url = "https://github.com/nextcloud-releases/mail/releases/download/v5.10.4/mail-v5.10.4.tar.gz";
      license = "agpl3Plus";
    };
    music = pkgs.fetchNextcloudApp {
      name = "music";
      appName = "music";
      appVersion = "3.1.0";
      hash = "sha256-bQ9NBo5R/en3f68ag+mAsVWuhREjr/ajlKrfLn4Tvtg=";
      url = "https://github.com/nc-music/music/releases/download/v3.1.0/nc-music-3.1.0.tar.gz";
      license = "agpl3Plus";
    };
    news = pkgs.fetchNextcloudApp {
      name = "news";
      appName = "news";
      appVersion = "28.6.0";
      hash = "sha256-25VyIvV7d5/hvWuT0IXzpgygLYHRrmqHg2pa+QQpK90=";
      url = "https://github.com/nextcloud/news/releases/download/28.6.0/news.tar.gz";
      license = "agpl3Plus";
    };
    notes = pkgs.fetchNextcloudApp {
      name = "notes";
      appName = "notes";
      appVersion = "6.0.1";
      hash = "sha256-/54d/UfkYLSPt8Coi4/zcheZx8mKXW34CIrvFEfYFLI=";
      url = "https://github.com/nextcloud-releases/notes/releases/download/v6.0.1/notes-v6.0.1.tar.gz";
      license = "agpl3Plus";
    };
    onlyoffice = pkgs.fetchNextcloudApp {
      name = "onlyoffice";
      appName = "onlyoffice";
      appVersion = "10.1.2";
      hash = "sha256-QaohaMbw7bncBqreb5W8XngzqqwqALnsGgT494xfr/E=";
      url = "https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v10.1.2/onlyoffice.tar.gz";
      license = "agpl3Plus";
    };
    polls = pkgs.fetchNextcloudApp {
      name = "polls";
      appName = "polls";
      appVersion = "9.1.4";
      hash = "sha256-FstOtAaGr3rvv5nmBUVlKlDm8QxxAjJHFdwMbCQywL4=";
      url = "https://github.com/nextcloud-releases/polls/releases/download/v9.1.4/polls-v9.1.4.tar.gz";
      license = "agpl3Plus";
    };
    qownnotesapi = pkgs.fetchNextcloudApp {
      name = "qownnotesapi";
      appName = "qownnotesapi";
      appVersion = "26.5.0";
      hash = "sha256-5ikl+SNEstpWy+uBKNE/bU0klBo3tr2Ylclq6szxHEM=";
      url = "https://github.com/pbek/qownnotesapi/releases/download/v26.5.0/qownnotesapi-nc.tar.gz";
      license = "agpl3Plus";
    };
    richdocuments = pkgs.fetchNextcloudApp {
      name = "richdocuments";
      appName = "richdocuments";
      appVersion = "10.2.0";
      hash = "sha256-HGNCueLlZuauHi/0dltApMDj8FBZ4Ruj2T2F+/4qWY4=";
      url = "https://github.com/nextcloud-releases/richdocuments/releases/download/v10.2.0/richdocuments-v10.2.0.tar.gz";
      license = "agpl3Plus";
    };
    tasks = pkgs.fetchNextcloudApp {
      name = "tasks";
      appName = "tasks";
      appVersion = "0.18.1";
      hash = "sha256-DJiNUFMcm/okbmwx8/lTaa3eFim6cNFRlJFatW4kaHs=";
      url = "https://github.com/nextcloud/tasks/releases/download/v0.18.1/tasks.tar.gz";
      license = "agpl3Plus";
    };
    whiteboard = pkgs.fetchNextcloudApp {
      name = "whiteboard";
      appName = "whiteboard";
      appVersion = "1.5.9";
      hash = "sha256-GV5dCxn7t+F2vSyJur/VUUrvAiSv5dDvI5ME6EBGof4=";
      url = "https://github.com/nextcloud-releases/whiteboard/releases/download/v1.5.9/whiteboard-v1.5.9.tar.gz";
      license = "agpl3Plus";
    };
  };
in
{
  options.modules.services.nextcloud = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      postgresql = {
        enable = true;
        package = pkgs.postgresql_16;
      };
      # Thanks to Carlos Vaz for this simple configuration example
      # See https://carlosvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/
      nextcloud = {
        enable = true;
        hostName = "cloud.${domain}";

        # Need to manually increment with every major upgrade.
        package = nextcloudPackage;

        # Let NixOS install and configure the database automatically.
        database.createLocally = true;

        # Let NixOS install and configure Redis caching automatically.
        configureRedis = true;

        # Increase the maximum file upload size to avoid problems uploading videos.
        maxUploadSize = "16G";
        https = true;

        autoUpdateApps.enable = true;
        # To be able to install apps, even if they are failing in nixpkgs
        appstoreEnable = true;
        extraAppsEnable = true;
        extraApps =
          lib.genAttrs selectedAppNames (name: builtins.getAttr name nc4nixApps);

        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        # phonetrack = pkgs.fetchNextcloudApp {
        #   name = "phonetrack";
        #   sha256 = "0qf366vbahyl27p9mshfma1as4nvql6w75zy2zk5xwwbp343vsbc";
        #   url = "https://gitlab.com/eneiluj/phonetrack-oc/-/wikis/uploads/931aaaf8dca24bf31a7e169a83c17235/phonetrack-0.6.9.tar.gz";
        #   version = "0.6.9";
        # };

        settings = {
          overwriteprotocol = "https";
          default_phone_region = "AT";
        };

        config = {
          dbtype = "pgsql";
          adminuser = "admin";
          adminpassFile = "/var/secrets/nextcloud";
        };
      };

      # onlyoffice = {
      #   enable = true;
      #   hostname = "onlyoffice.${domain}";
      # };

      nginx.virtualHosts = {
        # "onlyoffice.${domain}" = {
          # forceSSL = true;
          # enableACME = true;
        # };
        "cloud.${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/whiteboard" = {
              proxyPass = "http://localhost:3002";
              proxyWebsockets = true;
              extraConfig =
                  "proxy_ssl_server_name on;" +
                  "proxy_pass_header Authorization;";
          };
        };

        "nextcloud.${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".return = "301 https://cloud.${domain}$request_uri";
        };
      };

      nextcloud-whiteboard-server = {
        enable = true;
        settings.NEXTCLOUD_URL = "https://cloud.thym.at";
        secrets = [ "/var/secrets/nextcloud-whiteboard-server" ];
      };
    };

    security.acme = {
      acceptTerms = mkDefault true;
      certs = {
        "cloud.${domain}" = {
          email = "${adminEmail}";
        };
      };
    };
  };
}
