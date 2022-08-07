# modules/desktop/plank.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.plank;
in {
  options.modules.desktop.plank = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Elegant, simple, clean dock
      plank
    ];

    home.dconfSettings = {
      "net/launchpad/plank/docks/default" = {
        alignment = "center";
        auto-pinning = true;
        current-workspace-only = false;
        hide-delay = 0;
        hide-mode = "auto";
        icon-size = 128;
        items-alignment = "center";
        lock-items = true;
        monitor = "";
        offset = 0;
        pinned-only = true;
        position = "bottom";
        pressure-reveal = false;
        show-dock-item = false;
        theme = "Transparent";
        tooltips-enabled = false;
        unhide-delay = 0;
        zoom-enabled = true;
        zoom-percent = 200;
        dock-items = [
          "kitty.dockitem"
          "firefox.dockitem"
          "thunar.dockitem"
          "keepassxc.dockitem"
          "mullvad.dockitem"
          "lollypop.dockitem"
          "signal.dockitem"
          "telegram.dockitem"
          "thunderbird.dockitem"
          "qownnotes.dockitem"
          "gimp.dockitem"
          "spectacle.dockitem"
          "mousepad.dockitem"
        ];
      };
    };

    home.configFile = {
      "plank/default/launchers/kitty.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/kitty.desktop
      '';
      "plank/default/launchers/firefox.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/firefox.desktop
      '';
      "plank/default/launchers/thunar.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/thunar.desktop
      '';
      "plank/default/launchers/keepassxc.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/org.keepassxc.KeePassXC.desktop
      '';
      "plank/default/launchers/mullvad.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///run/current-system/sw/share/applications/mullvad-vpn.desktop
      '';
      "plank/default/launchers/lollypop.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/org.gnome.Lollypop.desktop
      '';
      "plank/default/launchers/signal.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/signal-desktop.desktop
      '';
      "plank/default/launchers/telegram.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/telegramdesktop.desktop
      '';
      "plank/default/launchers/thunderbird.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/thunderbird.desktop
      '';
      "plank/default/launchers/qownnotes.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///home/mathym/.nix-profile/share/applications/PBE.QOwnNotes.desktop
      '';
      "plank/default/launchers/gimp.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/gimp.desktop
      '';
      "plank/default/launchers/spectacle.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/org.kde.spectacle.desktop
      '';
      "plank/default/launchers/mousepad.dockitem".text = ''
        [PlankDockItemPreferences]
        Launcher=file:///etc/profiles/per-user/mathym/share/applications/org.xfce.mousepad.desktop
      '';
    };
  };
}
