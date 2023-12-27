{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.headscale;
  domain = "xn--berwachungsbehr-mtb1g.de";
in
{
  options.modules.services.headscale = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8888;
        settings = {
          server_url = "https://headscale.${domain}";
          dns_config = {
            override_local_dns = true;
            baseDomain = "${domain}";
            magic_dns = true;
            domains = [ "headscale.${domain}" ];
            nameservers = [
              # No CloudFlare
              "9.9.9.9"
            ];
          };
          logtail.enabled = false;
          ip_prefixes = [
            # 46.38.243.234 -> xn--berwachungsbehr-mtb1g.de
            # headscale overlay network
            "100.64.0.0/10"
            "fd7a:115c:a1e0::/48"
          ];
        };
      };
    };

    user.extraGroups = [ "headscale" ];

    environment.systemPackages = [ config.services.headscale.package ];
  };
}
