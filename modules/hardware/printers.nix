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
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.brlaser ];

    environment.systemPackages = with pkgs; [
      # Printing settings utility
      system-config-printer
    ];
  };
}
