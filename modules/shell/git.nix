{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.git;
in {
  options.modules.shell.git = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Distributed version control system
      gitFull
      # Simple terminal UI for Git
      lazygit
      # Git repository summary on your terminal
      onefetch
      # Linting for your Git commit messages
      gitlint
      # A syntax-highlighting pager for Git
      delta
    ];

    home.configFile = {
      "git/config".source = "${configDir}/git/config";
      "git/ignore".source = "${configDir}/git/ignore";
      "gitlint/default.ini".source = "${configDir}/git/gitlint/default.ini";
    };

    modules.shell.zsh.rcFiles = [ "${configDir}/git/aliases.zsh" ];
  };
}
