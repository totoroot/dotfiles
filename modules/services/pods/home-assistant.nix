{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.pods.home-assistant;
  port = 7901;
  version = "2023.12.2";

  home-assistant-config = pkgs.writeText "configuration.yaml" ''
    default_config:
    frontend:
    history:
    logbook:
    map:

    # Web Server configuration
    http:
      server_host:
        - 0.0.0.0
        - '::'
      server_port: ${toString port}
      trusted_proxies:
        - 127.0.0.1
        - ::1
        - 100.64.0.5
        - fd7a:115c:a1e0::5

    # Home configuration
    homeassistant:
      name: Home
      time_zone: ${config.time.timeZone}
      country: AT
      latitude: ${toString config.location.latitude}
      longitude: ${toString config.location.longitude}
      elevation: 400
      unit_system: metric
      temperature_unit: C

    logger:
      default: info
      logs:
        bellows.ezsp: debug
        bellows.zigbee.application: debug
        homeassistant.components.zha: debug
        homeassistant.core: debug
        zhaquirks: debug
        zigpy: debug
        zigpy_cc: debug
        zigpy_deconz.api: debug
        zigpy_deconz.zigbee.application: debug
        zigpy_xbee.api: debug
        zigpy_xbee.zigbee.application: debug
        zigpy_zigate: debug

    lovelace:
      mode: storage
      resources: []

    # recorder:
    #   db_url: postgresql:///hass

    tts:
      - platform: google_translate
  '';
in
{
  options.modules.services.pods.home-assistant = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      home-assistant = {
        image = "ghcr.io/home-assistant/home-assistant:${version}";
        volumes = [
          "${home-assistant-config}:/config/configuration.yaml"
        ];
        extraOptions = [
          "--device=/dev/ttyUSB0"
          # "--device=/dev/ttyUSB1"
          "--network=host"
          # "--privileged"
        ];
        ports = [
          "${toString port}:${toString port}"
        ];
        autoStart = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ port ];
  };
}

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
#               "100.64.0.5"
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
