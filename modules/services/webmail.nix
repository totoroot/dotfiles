{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.webmail;

  domain = "xn--berwachungsbehr-mtb1g.de";
  subdomain = "mail";
  adminEmail = "admin@thym.at";
in
{
  options.modules.services.webmail = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.roundcube = {
       enable = true;
       # This is the url of the vhost, not necessarily the same as the fqdn of
       # the mailserver
       hostName = "${subdomain}.${domain}";
       extraConfig = ''
         # starttls needed for authentication, so the fqdn required to match
         # the certificate
         $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
         $config['smtp_user'] = "%u";
         $config['smtp_pass'] = "%p";
       '';
    };

    services.nginx.virtualHosts = {
      "${subdomain}.${domain}" = {
        forceSSL = true;
        enableACME = true;
      };
    };

    security.acme = {
      acceptTerms = mkDefault true;
      certs = {
        "${subdomain}.${domain}" = {
          email = "${adminEmail}";
        };
      };
    };
  };
}
