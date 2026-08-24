{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.nix.remoteBuilderServer;
in
{
  options.modules.nix.remoteBuilderServer = {
    enable = mkEnableOption "Nix remote builder server account";

    user = mkOption {
      type = types.str;
      default = "builder";
      description = "Unprivileged account used by remote Nix clients.";
    };

    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "Primary group of the remote builder account.";
    };

    home = mkOption {
      type = types.str;
      default = "/var/lib/${cfg.user}";
      description = "Home directory of the remote builder account.";
    };

    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "SSH public keys authorized to use the remote builder account.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.authorizedKeys != [ ];
        message = "modules.nix.remoteBuilderServer.authorizedKeys must not be empty.";
      }
    ];

    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      inherit (cfg) group home;
      createHome = true;
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    nix.settings = {
      trusted-users = mkAfter [ cfg.user ];
      allowed-users = mkAfter [ cfg.user ];
    };
  };
}
