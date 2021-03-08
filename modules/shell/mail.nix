# modules/shell/mail.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.mail;
in {
  options.modules.shell.mail = {
    enable          = mkBoolOpt false;
    desktop.enable  = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      (if cfg.enable then [
        unstable.aerc # TUI email client with vim keybindings
        w3m           # text based browser for displaying html emails
      ] else []) ++

      (if cfg.desktop.enable then [
        sylpheed      # lightweight GUI email client
      ] else []);

    home.configFile = {
      # to import accounts move accounts.conf to dir and chmod 600
      "aerc/binds.conf".source = "${configDir}/aerc/binds.conf";
      "aerc/aerc.conf".source = "${configDir}/aerc/aerc.conf";
      "aerc/filters".source = "${configDir}/aerc/filters";
      "aerc/templates".source = "${configDir}/aerc/templates";
    };
  };
}
