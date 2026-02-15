{ options, config, lib, inputs, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.adventurelog;
  domain = "xn--berwachungsbehr-mtb1g.de";
  frontendHost = "reise.${domain}";
in
{
  options.modules.services.adventurelog = {
    enable = mkBoolOpt false;
  };

  imports = [
    inputs.adventurelog.nixosModules.adventurelog
  ];

  config = mkIf cfg.enable {
    services.adventurelog = {
      enable = true;
      nginx.enable = true;
      nginx.hostName = frontendHost;
      nginx.frontendHostName = frontendHost;
      database.createLocally = true;
    };

    services.postgresql.package = lib.mkForce pkgs.postgresql_16;

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
