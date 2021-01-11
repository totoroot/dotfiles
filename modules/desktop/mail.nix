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
      # install aerc version from nixpkgs (often not latest)
      unstable.aerc
      w3m
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
