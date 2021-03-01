# modules/desktop/media/mail.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.mail;
in {
  options.modules.desktop.mail = {
    enable             = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      unstable.aerc     # TUI email client with vim keybindings
      w3m               # text based browser for displaying html emails
      sylpheed          # lightweight GUI email client
    ];

    home.configFile = {
      # to import accounts move accounts.conf to dir and chmod 600
      "aerc/binds.conf".source = "${configDir}/aerc/binds.conf";
      "aerc/aerc.conf".source = "${configDir}/aerc/aerc.conf";
      "aerc/filters".source = "${configDir}/aerc/filters";
      "aerc/templates".source = "${configDir}/aerc/templates";
    };
  };
}
