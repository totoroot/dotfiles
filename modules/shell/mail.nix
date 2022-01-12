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
        # TUI email client with vim keybindings
        aerc
        # text based browser for displaying html emails
        w3m
      ] else []) ++

      (if cfg.desktop.enable then [
        # lightweight GUI email client
        # sylpheed
        # a full-featured email client
        thunderbird
        # mail system tray notification icon for Thunderbird
        birdtray
      ] else []);

    home.configFile = {
      # to import accounts move accounts.conf to dir and chmod 600
      "aerc/binds.conf".source = "${configDir}/aerc/binds.conf";
      "aerc/aerc.conf".source = "${configDir}/aerc/aerc.conf";
      "aerc/filters".source = "${configDir}/aerc/filters";
      "aerc/templates".source = "${configDir}/aerc/templates";
      # after istalling thunderbird and importing the profile open thunderbird with
      # `thunderbird -ProfileManager &` and choose the profile directory
      "thunderbird/profiles.ini".source = "${configDir}/thunderbird/profiles.ini";
      "thunderbird/installs.ini".source = "${configDir}/thunderbird/installs.ini";
      "thunderbird/signature-professional.html".source = "${configDir}/thunderbird/signature-professional.html";
    };
  };
}
