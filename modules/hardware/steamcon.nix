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
      # A standalone Steam controller driver
      # steamcontroller
      # User-mode driver and GUI for Steam Controller and other controllers
      sc-controller
    ];

    # See https://wiki.archlinux.org/title/Gamepad#Steam_Controller_not_pairing for more info
    services.udev = {
      extraRules = ''
        # This file allows SC-Controller application and daemon to access Steam Controller or its USB dongle.
        # This is done by allowing read/write access to all users. You may want to change this to something like
        # MODE="0660", GROUP="games" to allow r/w access only to members of that group.

        # Valve USB devices
        SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
        # Valve HID devices over bluetooth hidraw
        KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666", TAG+="uaccess"
        # Sony USB devices
        SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", MODE="0666"
        # Sony input devices over bluetooth
        SUBSYSTEM=="input", KERNELS=="*054C:09CC*", MODE="0666", TAG+="uaccess"
        # uinput kernel module write access (allows keyboard, mouse and gamepad emulation)
        KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", MODE="0666"
        '';
    };

    home.configFile = {
      "scc/config.json".source = "${configDir}/steamcon/config.json";
      "scc/menus/.use".source = "${configDir}/steamcon/menus/.use";
      "scc/profiles/steam-controller-desktop.sccprofile".source = "${configDir}/steamcon/profiles/steam-controller-desktop.sccprofile";
      "scc/profiles/steam-controller-game.sccprofile".source = "${configDir}/steamcon/profiles/steam-controller-game.sccprofile";
    };
  };
}
