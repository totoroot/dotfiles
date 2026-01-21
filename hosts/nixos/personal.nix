{ config, lib, ... }:

with lib;
{
  networking.hosts =
    let
      hostConfig = {
        # Public IP Main VPS
        "45.83.104.124" = [ "jam" ];

        # Wifi Router
        "10.0.0.1" = [ "white" ];
        # Desktop PC
        "10.0.0.2" = [ "purple" ];
        # Home Server
        "10.0.0.3" = [ "violet" ];
        # Private Notebook
        "10.0.0.4" = [ "grape" ];
        # Smartphone
        "10.0.0.5" = [ "fp5" ];
        # Mac mini
        "10.0.0.6" = [ "wine" ];

        "192.168.0.20" = [ "black" ];
        "193.30.121.17" = [ "phlox" ];

        "100.64.0.1" = [ "jam-ts" ];
        "100.64.0.2" = [ "purple-ts" ];
        "100.64.0.3" = [ "violet-ts" ];
        "100.64.0.4" = [ "grape-ts" ];
        "100.64.0.5" = [ "fp5-ts" ];
        # "100.64.0.6" = [ "wine-ts" ];

        # "192.168.0.4" = [ "printer" ];
        # "192.168.8.103" = [ "Lakka" ];
        # "192.168.8.105" = [ "steamdeck" ];
        # "192.168.8.106" = [ "raspberry" ];
        # "192.168.8.107" = [ "grape" ];
        # "192.168.8.108" = [ "sangria" ];
        # "192.168.8.109" = [ "mulberry" ];
        # "192.168.8.254" = [ "moooh" ];
      };
      hosts = flatten (attrValues hostConfig);
      hostName = config.networking.hostName;
    in
    mkIf (builtins.elem hostName hosts) hostConfig;

  ## Location config -- since Vienna is my 127.0.0.1
  time.timeZone = mkDefault "Europe/Vienna";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # For redshift, mainly
  # Go try find my home with those coordinates
  # as those are randomly picked within a range near my home
  location = (if config.time.timeZone == "Europe/Vienna" then {
    latitude = 47.064;
    longitude = 15.428;
  } else { });
}
