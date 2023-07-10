{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.printers;
in
{
  options.modules.hardware.printers = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # Brother laser printer goes BRRRRRrrrrr
    services.printing = {
      # Enables printing on Linux with CUPS
      # After install, CUPS is available at http://localhost:631/
      enable = true;
      drivers = with pkgs; [ gutenprint brlaser ];
    };

    environment.systemPackages = with pkgs; [
      # Printing settings utility
      system-config-printer
    ];

    home.configFile = {
      # Link PPD files for printers
      "printers" = {
        recursive = true;
        source = "${configDir}/printers";
      };
    };
  };
}
