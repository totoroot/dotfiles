{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.sops;
  hostName = lib.attrsets.attrByPath [ "networking" "hostName" ] null config;
  keyFile =
    if hostName != null then "/var/lib/sops-nix/${hostName}.txt" else "/var/lib/sops-nix/$(hostname -s).txt";
in
{
  options.modules.home.sops = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ sops age ];
    modules.home.zsh.rcInit = ''
      sops() { SOPS_AGE_KEY_FILE="${keyFile}" TERM=xterm SOPS_EDITOR="micro" command sops "$@"; }
      sops-edit() { SOPS_AGE_KEY_FILE="${keyFile}" TERM=xterm SOPS_EDITOR="micro" command sops "$@"; }
    '';
  };
}
