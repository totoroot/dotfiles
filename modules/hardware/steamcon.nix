{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.steamcon;
in {
  options.modules.hardware.steamcon = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # steamcontroller
      sc-controller
    ];

    # See https://wiki.archlinux.org/title/Gamepad#Steam_Controller_not_pairing for more info
    services.udev = {
      extraRules = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
        '';
    };
  };
}
