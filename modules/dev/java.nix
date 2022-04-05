# modules/dev/java.nix

{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let cfg = config.modules.dev.java;
in {
  options.modules.dev.java = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    programs.java.enable = true;

    user.packages = with pkgs; [
      # Integrated Development Environment (IDE) by Jetbrains, requires paid license
      jetbrains.idea-ultimate
      # The open-source Java Development Kit
      jdk
      # Java build automation tool
      maven
    ];

    env.JAVA_HOME = [ "$(readlink -e $(type -p java) | sed  -e 's/\/bin\/java//g')" ];

    environment.shellAliases = {
      intellij = "idea-ultimate";
    };

    home.configFile = {
      "JetBrains/IntelliJIdea2021.3/keymaps/custom.xml".source = "${configDir}/jetbrains/keymaps/custom.xml";
    };
  };
}
