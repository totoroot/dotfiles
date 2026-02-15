{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.recipes;
  domain = "xn--berwachungsbehr-mtb1g.de";
  port = 8491;
in
{
  options.modules.services.recipes = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.tandoor-recipes = {
      enable = true;
      address = "recipes.${domain}";
      port = port;
      # https://raw.githubusercontent.com/vabene1111/recipes/master/.env.template
      extraConfig = {
        MEDIA_ROOT = "/var/lib/tandoor-recipes/media";
      };
    };

    environment.systemPackages = [ config.services.tandoor-recipes.package ];
  };
}
