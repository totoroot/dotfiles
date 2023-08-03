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
      wally-cli
    ];

    # See https://github.com/zsa/wally/wiki for more info
    services.udev = {
      extraRules = ''
        # STM32 rules for the ZSA Moonlander keyboard
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
        # Oryx live training rule for ZSA Moonlander keyboard
        SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
        '';
    }; 

    user.extraGroups = [ "plugdev" ]; 
  };
}
