{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.environments.xfce;
in {
  options.modules.desktop.environments.xfce = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      # Display Manager for XFCE
      displayManager.sddm = {
        enable = true;
        extraPackages = let
          sddmDracula =
            lib.attrByPath [ "sddm-theme-dracula" ] null pkgs
            or (lib.attrByPath [ "sddmThemes" "dracula" ] null pkgs);
        in
        lib.optional (sddmDracula != null) sddmDracula;
      };
      xserver = {
        enable = true;
        displayManager.lightdm.enable = false;
        # Enable XFCE and its modules itself
        desktopManager = {
          xfce = {
            enable = true;
            enableScreensaver = true;
            enableXfwm = true;
          };
        };
      };
      # Use GNOME keyring for WiFi key management
      gnome.gnome-keyring.enable = true;
    };

    # Unlock GNOME keyring when logged in via SDDM
    security.pam.services.sddm.enableGnomeKeyring = true;

    environment.systemPackages = with pkgs; [
      # A dbus session bus service that is used to bring up authentication dialogs
      polkit_gnome
    ];
  };
}
