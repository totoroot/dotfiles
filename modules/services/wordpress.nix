{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.wordpress;
  cysDomain = "cambodianyouthsupport.com";
  oldWordpress = import (builtins.fetchGit {
     # Descriptive name to make the store path easier to identify
     name = "wordpress-version-5_7_2";
     url = "https://github.com/NixOS/nixpkgs/";
     ref = "refs/heads/nixpkgs-unstable";
     rev = "c8e344196154514112c938f2814e809b1ca82da1";
  }) {};
in
{
  options.modules.services.wordpress = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    # See https://discourse.nixos.org/t/can-i-install-mutable-wordpress-in-nixos/37479/2

    # Create /var/www/wordpress and set ownership to user/group
    users = {
      users.www-wordpress= {
        isNormalUser = true;
        group = "www-wordpress";
        packages = with pkgs; [
          php82
          php82.packages.composer
        ];
      };
      groups.www-wordpress = { };
    };

    services = {
      phpfpm.pools."wordpress-cys" = {
        phpPackage = pkgs.php82;
        # user = "www-wordpress";
        # group = "www-wordpress";
        settings = {
          "listen.owner" = config.services.nginx.user;
          "listen.group" = config.services.nginx.group;
        };
      };

      mysql = {
        enable = true;
        package = pkgs.mariadb;
        ensureDatabases = [ "wordpress-cys" ];
        ensureUsers = [
          { name = "www-wordpress";
            ensurePermissions = {
              # whatever wordpress requires you can put here
            };
          }
        ];
      };

      wordpress = {
        webserver = "nginx";
        sites = {
          "cys" = {
            settings = {
              WP_SITEURL = "https://cambodianyouthsupport.com";
              WP_HOME = "https://cambodianyouthsupport.com";
              WP_DEBUG = true;
              FORCE_SSL_ADMIN = true;
              AUTOMATIC_UPDATER_DISABLED = true;
            };
            extraConfig = ''
              $_SERVER['HTTPS']='on';
            '';
            package = oldWordpress.wordpress;
            poolConfig = {
              "pm" = "dynamic";
              # Tweak the below options as needed, though the can be a decent start depending on your work load
              "pm.max_children" = 16;
              "pm.start_servers" = 4;
              "pm.min_spare_servers" = 2;
              "pm.max_spare_servers" = 4;
              "pm.max_requests" = 2000;
            };
          };
        };
      };

      nginx.virtualHosts."${cysDomain}" = {
        enableACME = true;
        forceSSL = true;
        serverAliases = [ "www.${cysDomain}" ];
        root = "/var/www/wordpress-cys";
      };
    };
  };
}
