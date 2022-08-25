{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.bspwm;
in {
  options.modules.desktop.bspwm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.theme.onReload.bspwm = ''
      ${pkgs.bspwm}/bin/bspc wm -r
      source $XDG_CONFIG_HOME/bspwm/bspwmrc
    '';

    environment.systemPackages = with pkgs; [
      # Adds layout managing capabilities for bspwm
      unstable.bsp-layout
      # Cross-desktop display manager
      lightdm
      # Lightweight and customizable notification daemon
      dunst
      # Library that sends desktop notifications to a notification daemon
      libnotify
      # X11 screen lock utility with security in mind
      xsecurelock
      # Use external locker (such as i3lock) as X screen saver
      xss-lock
      # Launch a given program when your X session has been idle for a given time
      xautolock
      # xautolock rewrite in Rust, with a few extra features
      # xidlehook
      # i3lock is a bash script that takes a screenshot of the desktop, blurs the background and adds a lock icon and text
      i3lock-fancy

      (polybar.override {
        pulseSupport = true;
        nlSupport = true;
      })
    ];

    services = {
      picom.enable = true;
      redshift.enable = true;
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+bspwm";
          lightdm.enable = true;
          lightdm.greeters.mini.enable = true;
          sessionCommands = pkgs.lib.mkAfter ''
            ${pkgs.xorg.xset}/bin/xset s 600 10
            ${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- ${pkgs.xautolock}/bin/xautolock -locknow &
            ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
          '';
        };
        xautolock = {
          enable = true;
          time = 30;
          # enableNotifier = true;
          # notify = 30;
          # notifier = "${pkgs.libnotify}/bin/notify-send 'Locking in 30 seconds'";
          locker = "${pkgs.xsecurelock}/bin/xsecurelock";
          nowlocker = "${pkgs.xsecurelock}/bin/xsecurelock";
          killer = "/run/current-system/systemd/bin/systemctl suspend";
          killtime = 30;
          # extraOptions = [
            # "-detectsleep"
          # ];
        };
        windowManager.bspwm.enable = true;
      };
    };

    systemd.user.services."dunst" = {
      enable = true;
      description = "";
      wantedBy = [ "default.target" ];
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
    };

    # link recursively so other modules can link files in their folders
    home.configFile = {
      "sxhkd".source = "${configDir}/sxhkd";
      "bspwm" = {
        source = "${configDir}/bspwm";
        recursive = true;
      };
    };
  };
}
