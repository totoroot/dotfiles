{ options, config, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.pods.languagetool;
in {
  options.modules.services.pods.languagetool = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "docker";
      containers."languagetool" = {
        autoStart = true;
        image = "erikvl87/languagetool:6.1";
        ports = [
          "8081:8010"
        ];
        volumes = [
          "/var/cache/languagetool/ngrams:/ngrams"
        ];
        environment = {
          langtool_languageModel = "/ngrams";
          # Minimal Java heap size
          Java_Xms = "256m";
          # Maximum Java heap size
          Java_Xmx = "2g";
        };
      };
    };
    systemd.services.docker-languagetool.serviceConfig = {
      User = "mathym";
      Group = "docker";
      CacheDirectory = "languagetool";
      CacheDirectoryMode = "0750";
    };
  };
}
