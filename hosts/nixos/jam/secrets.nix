{ config, lib, ... }:

let
  secretsFile = builtins.path {
    path = ../../../secrets/jam.yaml;
    name = "jam-secrets";
  };
  mkSecret = { key, path, owner ? "root", group ? "root", mode ? "0400", format ? "yaml" }: {
    sopsFile = secretsFile;
    inherit key path owner mode format;
  } // lib.optionalAttrs (group != null) { inherit group; };
in
{
  sops = {
    age.keyFile = "/var/lib/sops-nix/jam.txt";
    useSystemdActivation = true;
    secrets = {
      attic-client-env = mkSecret {
        key = "ATTICD_ENV";
        path = "/etc/atticd.env";
      };
      nextcloud-exporter-token = mkSecret {
        key = "NEXTCLOUD_EXPORTER_TOKEN";
        path = "/var/secrets/nextcloud-exporter.token";
        owner = "nextcloud-exporter";
        group = "nextcloud-exporter";
      };
      prometheus-home-assistant-api-token = mkSecret {
        key = "PROMETHEUS_HOME_ASSISTANT_API_TOKEN";
        path = "/var/secrets/prometheus-home-assistant-api.token";
        group = "prometheus";
        mode = "0440";
      };
      vaultwarden-database-url = mkSecret {
        key = "VAULTWARDEN_DATABASE_URL";
        path = "/var/secrets/vaultwarden-db.env";
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0400";
      };
      gitlab-runner-default-token = mkSecret {
        key = "GITLAB_RUNNER_DEFAULT_TOKEN_ENV";
        path = "/var/secrets/gitlab-runner-default-token.env";
      };
      gitlab-runner-nix-token = mkSecret {
        key = "GITLAB_RUNNER_NIX_TOKEN_ENV";
        path = "/var/secrets/gitlab-runner-nix-token.env";
      };
      forgejo-runner-codeberg-token = mkSecret {
        key = "FORGEJO_RUNNER_CODEBERG_TOKEN";
        path = "/var/secrets/forgejo-runner-codeberg.token";
        mode = "0440";
      };
      authelia-users-database = mkSecret {
        key = "AUTHELIA_USERS_DATABASE";
        path = "/var/secrets/authelia/users_database.yml";
        owner = "authelia";
        group = "authelia";
        mode = "0400";
      };
      authelia-jwt-secret = mkSecret {
        key = "AUTHELIA_JWT_SECRET";
        path = "/var/secrets/authelia/jwt_secret";
        owner = "authelia";
        group = "authelia";
        mode = "0400";
      };
      authelia-storage-encryption-key = mkSecret {
        key = "AUTHELIA_STORAGE_ENCRYPTION_KEY";
        path = "/var/secrets/authelia/storage_encryption_key";
        owner = "authelia";
        group = "authelia";
        mode = "0400";
      };
      authelia-session-secret = mkSecret {
        key = "AUTHELIA_SESSION_SECRET";
        path = "/var/secrets/authelia/session_secret";
        owner = "authelia";
        group = "authelia";
        mode = "0400";
      };
      acme-netcup-customer-number = mkSecret {
        key = "ACME_NETCUP_CUSTOMER_NUMBER";
        path = "/var/secrets/acme/netcup-customer-number";
      };
      acme-netcup-api-key = mkSecret {
        key = "ACME_NETCUP_API_KEY";
        path = "/var/secrets/acme/netcup-api-key";
      };
      acme-netcup-api-password = mkSecret {
        key = "ACME_NETCUP_API_PASSWORD";
        path = "/var/secrets/acme/netcup-api-password";
      };
      plausible-keybase = mkSecret {
        key = "PLAUSIBLE_SECRET_KEYBASE";
        path = "/var/secrets/plausible/keybase";
        mode = "0400";
      };
      mailserver-admin-thym-it-password-hash = mkSecret {
        key = "MAILSERVER_ADMIN_THYM_IT_PASSWORD_HASH";
        path = "/var/secrets/mailserver/admin@thym.it";
        mode = "0400";
      };
    };
  };
}
