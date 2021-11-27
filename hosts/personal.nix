{ config, lib, ... }:

with lib;
{
  networking.hosts =
    let hostConfig = {
          "192.168.8.1"   = [ "white" ];
          "192.168.8.101" = [ "purple" ];
          "192.168.8.102" = [ "violet" ];
        };
        hosts = flatten (attrValues hostConfig);
        hostName = config.networking.hostName;
    in mkIf (builtins.elem hostName hosts) hostConfig;

  ## Location config -- since Vienna is my 127.0.0.1
  time.timeZone = mkDefault "Europe/Vienna";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";
  # For redshift, mainly
  # Go try find my home with those coordinates 
  # as those are randomly picked within a range near my home
  location = (if config.time.timeZone == "Europe/Vienna" then {
    latitude = 47.064;
    longitude = 15.428;
  } else {});
}
