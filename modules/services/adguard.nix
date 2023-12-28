{ options, config, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.adguard;
in {
  options.modules.services.adguard = {
    enable = mkBoolOpt false;
    adguardPort = 3300;
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      mutableSettings = true;
      settings = {
        bind_host = "0.0.0.0";
        bind_port = adguardPort;
      };
    };
  };
}
