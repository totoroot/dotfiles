{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.home.git;
in {
  options.modules.home.git = {
    enable = mkBoolOpt false;
  };

  imports = [
    ./config-symlinks.nix
    ./zsh.nix
  ];

  config = mkIf cfg.enable {
    modules.home.configSymlinks.enable = true;
    modules.home.configSymlinks.force = true;

    home.packages = with pkgs; [
      # Distributed version control system
      gitFull
      # Git extension for versioning large files
      git-lfs
      # Simple terminal UI for Git
      lazygit
      # Git repository summary on your terminal
      onefetch
      # Linting for your Git commit messages
      gitlint
      # A syntax-highlighting pager for Git
      delta
      # CLI Tool for Codeberg similar to gh and glab
      codeberg-cli
    ];

    programs.git.includes = {
      path = "${configDir}/git/config";
    };

    modules.home.configSymlinks.entries =
      (map (name: "git/${name}") [
        "config"
        "ignore"
        "workconfig"
        "privateconfig"
      ]) ++
      (map (name: "gitlint/${name}") [
        "default.ini"
      ]);

    modules.home.zsh.rcFiles = [ "${configDir}/git/aliases.zsh" ];
  };
}
