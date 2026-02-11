{ config, pkgs, options, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.mailserver;

  domain = "xn--berwachungsbehr-mtb1g.de";
  praxisDomain = "grueneis-psychologie.at";
  release = "25.05";
in
{

  imports = lib.optionals cfg.enable [
    # (pkgs.fetchFromGitLab {
    #   owner = "simple-nixos-mailserver";
    #   repo = "nixos-mailserver";
    #   rev = "master";
    #   hash = "";
    # })
    (builtins.fetchTarball {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";
      sha256 = "0pqc7bay9v360x2b7irqaz4ly63gp4z859cgg5c04imknv0pwjqw";
    })
    # (builtins.fetchTarball {
    #   # Pick a release version you are interested in and set its hash, e.g.
    #   url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-${release}/nixos-mailserver-nixos-${release}.tar.gz";
    #   # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
    #   # release="nixos-24.11"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
    #   sha256 = "1qn5fg0h62r82q7xw54ib9wcpflakix2db2mahbicx540562la1y";
    # })
  ];

  options.modules.services.mailserver = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    mailserver = {
      enable = true;
      stateVersion = 3;
      fqdn = "mail.${domain}";
      domains = [
        "${domain}"
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
      loginAccounts = {
        "admin@${domain}" = {
          hashedPasswordFile = "/var/secrets/mailserver/admin@überwachungsbehör.de";
          aliases = ["info@${domain}"];
        };
        "praxis@${praxisDomain}" = {
          hashedPasswordFile = "/var/secrets/mailserver/praxis@${praxisDomain}";
          aliases = ["clemens@${praxisDomain}"];
        };
      };

      # down nginx and opens port 80.
      certificateScheme = "acme-nginx";
    };
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "admin@thym.at";

    # services.opendkim = {
    #   enable = true;
    #   keyPath = "/var/lib/opendkim/keys";
    #   domains = "csl:xn--berwachungsbehr-mtb1g.de,grueneis-psychologie.at";
    # };
  };
}
