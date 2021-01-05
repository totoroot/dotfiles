# modules/desktop/media/mail.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.mail;
in {
  options.modules.desktop.mail = {
    enable             = mkBoolOpt false;
    aerc.enable        = mkBoolOpt true;
    evolution.enable   = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # install aerc version from nixpkgs (often not latest)
      (mkIf cfg.aerc.enable unstable.aerc)
      (mkIf cfg.aerc.enable w3m)
      (mkIf cfg.evolution.enable gnome3.evolution)
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
