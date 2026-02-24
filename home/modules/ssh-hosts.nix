{ config, options, lib, pkgs, ... }:

with lib;
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
  jamPort = 21042;
  defaultEntriesWithPorts =
    defaultEntries
    // {
      jam = (defaultEntries.jam or { host = "jam"; }) // { port = jamPort; };
      "jam-ts" = (defaultEntries."jam-ts" or { host = "jam-ts"; }) // { port = jamPort; };
    };
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
    enable = mkEnableOption "ssh host aliases";

    defaultUser = mkOption {
      type = nullOr str;
      default = null;
    };
    defaultIdentityFile = mkOption {
      type = nullOr str;
      default =
        let
          hostName = lib.attrsets.attrByPath [ "networking" "hostName" ] null config;
        in
        if pkgs.stdenv.isLinux && hostName != null then "~/.ssh/${hostName}" else null;
    };

    entries = mkOption {
      type = attrsOf (submodule ({ ... }: {
      options = {
        host = mkOption { type = nullOr str; default = null; };
        user = mkOption { type = nullOr str; default = null; };
        identityFile = mkOption { type = nullOr str; default = null; };
        port = mkOption { type = nullOr int; default = null; };
        extraOptions = mkOption { type = attrsOf str; default = { }; };
      };
    }));
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs.ssh.enable = true;
    programs.ssh.enableDefaultConfig = false;
    programs.ssh.includes = [ "~/.ssh/config.local" ];
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
      (mapAttrs mkMatchBlock (defaultEntriesWithPorts // cfg.entries))
    ];
  };
}
