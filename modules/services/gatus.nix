{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.gatus;
  domain = "xn--berwachungsbehr-mtb1g.de";
in
{
  options.modules.services.gatus = {
    enable = mkBoolOpt false;

    hostName = mkOpt types.str "status.${domain}";

    port = mkOpt types.port 8085;

    openFirewall = mkBoolOpt false;

    settings = mkOpt types.attrs { };

    endpoints = mkOpt (types.listOf types.attrs) [ ];
  };

  config = mkIf cfg.enable {
    services.gatus = {
      enable = true;
      openFirewall = cfg.openFirewall;
      settings = recursiveUpdate cfg.settings {
        web = {
          address = "127.0.0.1";
          port = cfg.port;
        };
        endpoints = cfg.endpoints;
      };
    };

    services.nginx.virtualHosts = mkIf config.modules.services.nginx.enable {
      "${cfg.hostName}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    environment.systemPackages = [ config.services.gatus.package ];
  };
}
