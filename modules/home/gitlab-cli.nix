{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.gitlab-cli;
in
{
  options.modules.home.gitlab-cli = {
    enable = mkBoolOpt false;
  };

  imports = [
    ./config-symlinks.nix
    ./git.nix
  ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # GitLab CLI tool bringing GitLab to your command line
      glab
    ];

    modules.home.configSymlinks.entries =
      (map (name: "gitlab-cli/${name}") [
        "config.yml"
      ]);
  };
}
