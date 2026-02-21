{ config, options, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.sshHosts;
  inherit (lib) filterAttrs mapAttrs;
  defaultHostConfig = import ../../hosts/ips.nix;
  defaultEntries =
    let
      pairs =
        concatMap
          (ip: map (name: { inherit name; value = { host = ip; }; }) defaultHostConfig.${ip})
          (attrNames defaultHostConfig);
    in
    listToAttrs pairs;
  mkMatchBlock = name: hostCfg:
    let
      user = hostCfg.user or cfg.defaultUser;
      identityFile = hostCfg.identityFile or cfg.defaultIdentityFile;
      port = hostCfg.port or null;
      extraOptions = hostCfg.extraOptions or { };
    in
    filterAttrs (_: v: v != null) ({
      hostname = hostCfg.host or name;
      inherit user identityFile port extraOptions;
    });
in
{
  options.modules.home.sshHosts = with types; {
    enable = mkBoolOpt false;

    defaultUser = mkOpt (nullOr str) null;
    defaultIdentityFile = mkOpt (nullOr str) null;

    entries = mkOpt (attrsOf (submodule ({ ... }: {
      options = {
        host = mkOpt (nullOr str) null;
        user = mkOpt (nullOr str) null;
        identityFile = mkOpt (nullOr str) null;
        port = mkOpt (nullOr int) null;
        extraOptions = mkOpt (attrsOf str) { };
      };
    }))) { };
  };

  config = mkIf cfg.enable {
    programs.ssh.enable = true;
    programs.ssh.enableDefaultConfig = false;
    programs.ssh.matchBlocks = mkMerge [
      {
        "*" = {
          serverAliveInterval = 30;
          serverAliveCountMax = 4;
          identitiesOnly = true;
          controlMaster = "auto";
          controlPersist = "10m";
          controlPath = "~/.ssh/cm-%r@%h:%p";
          extraOptions = {
            StrictHostKeyChecking = "accept-new";
          };
        };
      }
      (mapAttrs mkMatchBlock (defaultEntries // cfg.entries))
    ];
  };
}
