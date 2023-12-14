{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.languagetool;
  port = 6081;
in
{
  options.modules.services.languagetool = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      languagetool = {
        enable = true;
        port = port;
        public = true;
        settings = { };
      };
    };
  };
}
