{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.paperless;
  domain = "xn--berwachungsbehr-mtb1g.de";
in
{
  options.modules.services.paperless = {
    enable = mkBoolOpt false;
    port = mkOption {
      type = types.int;
      default = 28981;
    };
  };

  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      port = cfg.port;
      dataDir = "/var/lib/paperless";
      mediaDir = "/var/lib/paperless/media";
      consumptionDir = "/var/lib/paperless/consume";
      consumptionDirIsPublic = false;
      passwordFile = "/var/secrets/paperless";
      database.createLocally = true;
      settings = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_URL = "https://papier.${domain}";
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ cfg.port ];
  };
}
