{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.adguard;
  adguardHTTPPort = 3300;
  adguardDNSPort = 3301;
  domain = "xn--berwachungsbehr-mtb1g.de";
in
{
  options.modules.services.adguard = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      mutableSettings = true;
      settings = {
        bind_host = "0.0.0.0";
        bind_port = adguardDNSPort;
        http = {
          address = "0.0.0.0:${toString adguardHTTPPort}";
        };
      };
    };
  };
}
