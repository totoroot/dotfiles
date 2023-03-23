{ options, config, inputs, lib, pkgs, hyprland, ... }:

with lib;
with lib.my;

let
  cfg = config.modules.desktop.environments.hyprland;

  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  dbus-hyprland-environment = pkgs.writeTextFile {
    name = "dbus-hyprland-environment";
    destination = "/bin/dbus-hyprland-environment";
    executable = true;
    text = ''
      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_DESKTOP=Hyprland
      # systemctl --user stop pipewire pipewire-pulse wireplumber xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
      # systemctl --user start pipewire pipewire-pulse wireplumber xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
    '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gesettings/schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gesettings set $gnome_schema gtk-theme 'Adwaita'
      '';
  };
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
  }).defaultNix;
in {
  imports = [
    hyprland.nixosModules.default
  ];

  options.modules.desktop.environments.hyprland = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    programs = {
      hyprland = {
        enable = true;
        package = hyprland.packages.${pkgs.system}.default;
      };
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # Dynamic tiling Wayland compositor that doesn't sacrifice on its looks
      hyprland
      # The following two are from the hyprland flake...
      dbus-hyprland-environment
      configure-gtk
      # Core Wayland window system code and protocol
      egl-wayland
      # ElKowars wacky widgets
      eww-wayland
      # Window switcher, run dialog and dmenu replacement for Wayland
      rofi-wayland
      # Command-line copy/paste utilities for Wayland
      wl-clipboard
      # xrandr clone for wlroots compositors
      wlr-randr
      # Wallpaper tool for Wayland compositors
      swaybg
      # Day/night gamma adjustments for Wayland
      wlsunset
      # Highly customizable Wayland bar for Sway and Wlroots based compositors
      waybar
      # A lightweight Wayland notification daemon
      mako
      # Tiny dynamic menu for Wayland
      tofi
      # See https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/sway.nix#L60
      qt5.qtwayland
    ];


    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop).
    # The portal interfaces include APIs for file access, opening URIs,
    # printing and others.
    xdg.portal = {
      enable = true;
      # GTK portal needed to make GTK apps happy
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
      ];
      # gtkUsePortal = true;
    };

    environment.sessionVariables = rec {
      CLUTTER_BACKEND = "wayland";
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      MOZ_ENABLE_WAYLAND = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_BACKEND = "vulkan";
      # GDK_BACKEND = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      # QT_QPA_PLATFORMTHEME = "gtk2";
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      _JAVA_AWT_WM_NONREPARENTING = "1";
      # Better Wayland support for Electron-based apps
      # https://discourse.nixos.org/t/partly-overriding-a-desktop-entry/20743/2?u=totoroot
      NIXOS_OZONE_WL = "1";
    };

    security.rtkit.enable = true;

    services = {
      dbus.enable = true;
      # Login manager configuration
      greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet";
            # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland --time --asterisks --remember";
            user = "mathym";
          };
          default_session = initial_session;
        };
      };
    };

    # List of login environments for greetd
    environment.etc."greetd/environments".text = ''
      Hyprland
      plasmashell
      zsh
      bash
      sh
      nu
    '';

    home.configFile = {
      "hypr/hyprland.conf".source = "${configDir}/hypr/hyprland.conf";
      "mako/config".source = "${configDir}/mako/config";
      # "pipewire/pipewire-pulse.conf".source = "${configDir}/pipewire/pipewire-pulse.conf";
    };
  };
}
