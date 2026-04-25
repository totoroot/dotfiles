{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.handy;
in
{
  options.modules.desktop.handy = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      user.handy
      dotool
      wtype
      xdotool
    ];

    # Handy needs evdev access for global shortcuts and uinput for synthetic
    # text input. udev opens /dev/uinput to the input group.
    user.extraGroups = [ "input" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660"
    '';
  };
}
