{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.nextcloud;
  domain = "thym.at";
  adminEmail = "admin@thym.at";
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
        package = pkgs.nextcloud32;

        # Let NixOS install and configure the database automatically.
        database.createLocally = true;

        # Let NixOS install and configure Redis caching automatically.
        configureRedis = true;

        # Increase the maximum file upload size to avoid problems uploading videos.
        maxUploadSize = "16G";
        https = true;

        autoUpdateApps.enable = true;
        extraAppsEnable = true;
        extraApps = with config.services.nextcloud.package.packages.apps; {
          # List of apps we want to install and are already packaged in
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
          inherit bookmarks calendar contacts cookbook cospend deck files_automatedtagging forms groupfolders mail memories music news notes onlyoffice polls qownnotesapi richdocuments tasks whiteboard;
          # phonetrack = pkgs.fetchNextcloudApp {
          #   name = "phonetrack";
          #   sha256 = "0qf366vbahyl27p9mshfma1as4nvql6w75zy2zk5xwwbp343vsbc";
          #   url = "https://gitlab.com/eneiluj/phonetrack-oc/-/wikis/uploads/931aaaf8dca24bf31a7e169a83c17235/phonetrack-0.6.9.tar.gz";
          #   version = "0.6.9";
          # };
        };

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
