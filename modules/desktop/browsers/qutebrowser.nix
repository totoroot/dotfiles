# modules/browser/qutebrowser.nix --- https://github.com/qutebrowser/qutebrowser
#
# Qutebrowser is cute because it's not enough of a browser to be handsome.
# Still, we can all tell he'll grow up to be one hell of a lady-killer.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.browsers.qutebrowser;
in {
  options.modules.desktop.browsers.qutebrowser = with types; {
    enable = mkBoolOpt false;
    userStyles = mkOpt lines "";
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      qutebrowser
    ];

    home = {
      configFile."qutebrowser" = {
        source = "${configDir}/qutebrowser";
        recursive = true;
      };
      # dataFile."qutebrowser/userstyles.css".text = cfg.userStyles;
    };
  };
}
