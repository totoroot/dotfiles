{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.home-assistant;
  port = 7901;
  version = "2023.12.2";
in
{
  options.modules.services.home-assistant = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      home-assistant = {
        image = "ghcr.io/home-assistant/home-assistant:${version}";
        volumes = [
          # "${home-assistant-config}:/config/configuration.yaml"
          "/var/lib/home-assistant:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--device=/dev/ttyUSB0"
          # TODO Replace this with port mapping
          "--network=host"
        ];
        ports = [
          "${toString port}:${toString port}"
        ];
        autoStart = true;
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ port ];

    # Never got the ZigBee Home Automation Integration to work with the Home Assistant module

    #     services = {
    #       home-assistant = {
    #         enable = true;
    #         package =
    #           (pkgs.home-assistant.override {
    #             extraPackages = ps: [
    #               # Needed for PostgreSQL backend
    #               ps.psycopg2
    #             ];
    #           });
    #         config = {
    #           default_config = {};
    #           http = {
    #             server_port = port;
    #             trusted_proxies = [
    #               "127.0.0.1"
    #               "::1"
    #               "100.64.0.1"
    #               "fd7a:115c:a1e0::5"
    #             ];
    #             use_x_forwarded_for = true;
    #           };
    #           recorder.db_url = "postgresql://@/hass";
    #           homeassistant = {
    #             name = "Home";
    #             unit_system = "metric";
    #             time_zone = config.time.timeZone;
    #             temperature_unit = "C";
    #             # Set in $DOTFILES/hosts/personal.nix
    #             longitude = config.location.longitude;
    #             latitude = config.location.latitude;
    #           };
    #           frontend = { };
    #           history = { };
    #           logbook = { };
    #           map = { };
    #           tts = [ { platform = "google_translate"; } ];
    #           zha = {
    #             database_path = "/var/lib/hass/zigbee.db";
    #             enable_quirks = false;
    #           };
    #           logger = {
    #             default = "info";
    #             logs = {
    #               "homeassistant.core" = "debug";
    #               "homeassistant.components.zha" = "debug";
    #               "bellows.zigbee.application" = "debug";
    #               "bellows.ezsp" = "debug";
    #               "zigpy" = "debug";
    #               "zigpy_cc" = "debug";
    #               "zigpy_deconz.zigbee.application" = "debug";
    #               "zigpy_deconz.api" = "debug";
    #               "zigpy_xbee.zigbee.application" = "debug";
    #               "zigpy_xbee.api" = "debug";
    #               "zigpy_zigate" = "debug";
    #               "zhaquirks" = "debug";
    #             };
    #           };
    #         };
    #
    #         configDir = "/var/lib/home-assistant";
    #         configWritable = true;
    #         openFirewall = true;
    #         extraComponents = [
    #           "default_config"
    #           "zha"
    #           "esphome"
    #           "met"
    #           "radio_browser"
    #           "homeassistant"
    #         ];
    #       };
    #
    #       postgresql = {
    #         ensureDatabases = [ "hass" ];
    #         ensureUsers = [{
    #           name = "hass";
    #           ensureDBOwnership = true;
    #         }];
    #       };
    #     };
    #
    #     environment.systemPackages = [ config.services.home-assistant.package ];
  };
}
