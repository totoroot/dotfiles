# modules/desktop/mail.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.mail;
in {
  options.modules.desktop.mail = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Lightweight GUI email client
      # sylpheed
      # Full-featured email client
      thunderbird
      # Mail system tray notification icon for Thunderbird
      birdtray
    ];

    home.configFile = {
      # After istalling thunderbird and importing the profile open thunderbird with
      # `thunderbird -ProfileManager &` and choose the profile directory
      "thunderbird/profiles.ini".source = "${configDir}/thunderbird/profiles.ini";
      "thunderbird/installs.ini".source = "${configDir}/thunderbird/installs.ini";
      "thunderbird/signature-professional.html".source = "${configDir}/thunderbird/signature-professional.html";
      "birdtray-config.json".source = "${configDir}/thunderbird/birdtray-config.json";
    };
  };
}
