{ config, lib, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.mailserver;

  domain = "thym.it";
  legacyDomain = "xn--berwachungsbehr-mtb1g.de";
  praxisDomain = "grueneis-psychologie.at";
  mailserverModule = inputs.nixos-mailserver.nixosModules.default;
in
{

  imports = [ mailserverModule ];

  options.modules.services.mailserver = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    mailserver.enableNixpkgsReleaseCheck = mkDefault false;
    mailserver = {
      enable = true;
      stateVersion = 3;
      fqdn = "mail.${domain}";
      domains = [
        "${domain}"
        "${legacyDomain}"
        "${praxisDomain}"
      ];
      enableImap = true;
      enableSubmission = true;

      fullTextSearch = {
        enable = true;
        # Index new email as they arrive
        autoIndex = true;
        # This only applies to plain text attachments, binary attachments are never indexed
        # indexAttachments = true;
        enforced = "body";
      };

      # A list of all login accounts. To create the password hashes, use
      # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
      accounts = {
        "admin@${domain}" = {
          hashedPasswordFile = "/var/secrets/mailserver/admin@thym.it";
          aliases = [
            "info@${domain}"
            "hello@${domain}"
            "office@${domain}"
            "contact@${domain}"
            "admin@${legacyDomain}"
            "info@${legacyDomain}"
          ];
        };
        "praxis@${praxisDomain}" = {
          hashedPasswordFile = "/var/secrets/mailserver/praxis@${praxisDomain}";
          aliases = [
            "clemens@${praxisDomain}"
            "office@${praxisDomain}"
            "contact@${praxisDomain}"
            "hello@${praxisDomain}"
          ];
        };
      };

      # Use explicit ACME cert paths so dovecot always gets concrete file paths.
      x509 = {
        certificateFile = "/var/lib/acme/mail.${domain}/fullchain.pem";
        privateKeyFile = "/var/lib/acme/mail.${domain}/key.pem";
      };
    };
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "admin@thym.it";

    # services.opendkim = {
    #   enable = true;
    #   keyPath = "/var/lib/opendkim/keys";
    #   domains = "csl:xn--berwachungsbehr-mtb1g.de,grueneis-psychologie.at";
    # };
  };
}
