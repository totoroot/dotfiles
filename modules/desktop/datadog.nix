{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.datadog;
in {
  options.modules.desktop.datadog = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      firefox-wayland
      (makeDesktopItem {
        name = "datadog";
        desktopName = "Datadog";
        genericName = "Open Datadog in a separate Firefox window";
        icon = "datadog";
        exec = "${firefox-bin}/bin/firefox -new-window https://app.datadoghq.eu/dashboard/lists";
        categories = [ "Network" "X-Work" ];
      })
    ];
  };
}
