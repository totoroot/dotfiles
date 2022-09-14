# modules/desktop/browsers/chromium.nix
# I don't like Google. I don't like their browser. I don't like my RAM eaten up by its open-source variant. Sometimes I need it though.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.browsers.chromium;
in {
  options.modules.desktop.browsers.chromium = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ungoogled-chromium
      (makeDesktopItem {
        name = "chromium-incognito";
        desktopName = "Chromium (Incognito)";
        genericName = "Open an incognito Chromium window";
        icon = "chromium";
        exec = "${chromium}/bin/chromium --incognito";
        categories = [ "Network" ];
      })
    ];
  };
}
