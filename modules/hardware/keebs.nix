{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.keebs;
in {
  options.modules.hardware.keebs = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.wally-cli
    ];

    services.udev = {
      extraRules = ''
        # STM32 rules for the ZSA Moonlander keyboard
        # See https://github.com/zsa/wally/wiki/Linux-install for more info
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", \
        ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
      '';
    }; 

    user.extraGroups = [ "plugdev" ]; 
  };
}
