{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.photoprism;
  domain = "xn--berwachungsbehr-mtb1g.de";
  port = 7192;
in
{
  options.modules.services.photoprism = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.photoprism = {
      enable = true;
      address = "photos.${domain}";
      port = port;
      storagePath = "/var/lib/photoprism";
      originalsPath = "/mnt/photos";
      passwordFile = "/home/mathym/.config/dotfiles/secrets/photoprism.txt";
    };

    environment.systemPackages = [ config.services.photoprism.package ];
  };
}
