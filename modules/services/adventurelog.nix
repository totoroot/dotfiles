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
      backend.publicUrl = "https://${backendHost}";
      backend.frontendUrl = "https://${frontendHost}";
      frontend.origin = "https://${frontendHost}";
      nginx.enable = true;
      nginx.hostName = backendHost;
      database.createLocally = true;
    };

    services.nginx = {
      enable = true;
      virtualHosts.${backendHost} = {
        enableACME = true;
        forceSSL = true;
      };
      virtualHosts.${frontendHost} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${config.services.adventurelog.frontend.host}:${toString config.services.adventurelog.frontend.port}";
        };
      };
    };
  };
}
