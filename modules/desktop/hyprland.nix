{ options, config, inputs, lib, pkgs, ... }:

with lib;
with lib.my;

let 
  cfg = config.modules.desktop.hyprland;
  
  dbus-hyprland-environment = pkgs.writeTextFile {
    name = "dbus-hyprland-environment";
    destination = "/bin/dbus-hyprland-environment";
    executable = true;
    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

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
  
  options.modules.desktop.hyprland = {
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
      # The following two are from the hyprland flake...I think
      dbus-hyprland-environment
      configure-gtk
      # Core Wayland window system code and protocol
      wayland
      # ElKowars wacky widgets
      eww-wayland
      # Window switcher, run dialog and dmenu replacement for Wayland
      rofi-wayland
      # Command-line copy/paste utilities for Wayland
      wl-clipboard
      # Grab images from a Wayland compositor
      grim
      # An xrandr clone for wlroots compositors
      wlr-randr
      # Wallpaper tool for Wayland compositors
      swaybg
      # Day/night gamma adjustments for Wayland
      wlsunset
      # Highly customizable Wayland bar for Sway and Wlroots based compositors
      waybar
    ];

    services.dbus.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      gtkUsePortal = true;
    };

    environment.sessionVariables = rec {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "Hyprland";
          user = "mathym";
        };
        default_session = initial_session;
      };
    };

    environment.etc."greetd/environments".text = ''
      Hyprland
    '';

    home.configFile = {
      "hypr/hyprland.conf".source = "${configDir}/hypr/hyprland.conf";
    };
  };
}
