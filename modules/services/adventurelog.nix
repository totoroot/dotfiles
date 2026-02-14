{ options, config, lib, inputs, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.adventurelog;
  domain = "xn--berwachungsbehr-mtb1g.de";
  backendHost = "reise-api.${domain}";
  frontendHost = "reise.${domain}";
  adventurelogPkgs = inputs.adventurelog.packages.${pkgs.system} or { };
  adventurelogBackend = adventurelogPkgs.backend or adventurelogPkgs.default or null;
in
{
  options.modules.services.adventurelog = {
    enable = mkBoolOpt false;
  };

  imports = [
    inputs.adventurelog.nixosModules.adventurelog
  ];

  config = mkIf cfg.enable {

    nixpkgs.overlays = [
      inputs.adventurelog.overlays.default
    ];

    services.adventurelog = {
      enable = true;
      backend.package =
        inputs.adventurelog.packages.${pkgs.system}.adventurelog-backend.overrideAttrs (_: {
          src = "${inputs.adventurelog-src}/backend/server";
        });
      frontend.package =
        inputs.adventurelog.packages.${pkgs.system}.adventurelog-frontend.overrideAttrs (_: {
          src = "${inputs.adventurelog-src}/frontend";
        });
      backend.port = 2000;
      backend.publicUrl = "https://${frontendHost}";
      backend.frontendUrl = "https://${frontendHost}";
      frontend.port = 2104;
      frontend.origin = "https://${frontendHost}";
      frontend.publicServerUrl = "https://${frontendHost}/api";
      nginx.enable = true;
      nginx.hostName = backendHost;
      database.createLocally = true;
    };

    services.nginx = {
      enable = true;
      virtualHosts.${backendHost} = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          auth_basic off;
          auth_request off;
        '';
      };
      virtualHosts.${frontendHost} = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          auth_basic off;
          auth_request off;
        '';
        locations = {
          "/" = {
            extraConfig = ''
              auth_basic off;
              auth_request off;
            '';
            proxyPass = "http://${config.services.adventurelog.frontend.host}:${toString config.services.adventurelog.frontend.port}";
          };
          "/api/" = {
            extraConfig = ''
              auth_basic off;
              auth_request off;
            '';
            proxyPass = "http://${config.services.adventurelog.backend.host}:${toString config.services.adventurelog.backend.port}";
          };
          "/media/" = {
            extraConfig = ''
              auth_basic off;
              auth_request off;
            '';
            proxyPass = "http://${config.services.adventurelog.backend.host}:${toString config.services.adventurelog.backend.port}";
          };
          "/static/" = {
            extraConfig = ''
              auth_basic off;
              auth_request off;
            '';
            proxyPass = "http://${config.services.adventurelog.backend.host}:${toString config.services.adventurelog.backend.port}";
          };
        };
      };
    };

    services.postgresql.package = lib.mkForce pkgs.postgresql_16;

    security.acme = {
      acceptTerms = true;
      defaults.email = "admin@xn--berwachungsbehr-mtb1g.de";
    };

    systemd.services.adventurelog-backend.wants = [ "network-online.target" ];
    systemd.services.adventurelog-backend.after = [ "network-online.target" ];
    systemd.services.adventurelog-frontend.wants = [ "network-online.target" ];
    systemd.services.adventurelog-frontend.after = [ "network-online.target" ];
    systemd.services.adventurelog-backend.serviceConfig.StateDirectory = "adventurelog";

    systemd.tmpfiles.rules = [
      "d /var/lib/adventurelog/media 0750 adventurelog adventurelog -"
    ];
  };
}
