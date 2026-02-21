{ config, lib, ... }:

with lib;
{
  networking.hosts =
    let
      hostConfig = import ../../hosts/ips.nix;
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
