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
          greeterBin = "${pkgs.kdePackages.sddm}/bin/sddm-greeter";
          sddmDraculaRaw =
            if pkgs ? sddm-theme-dracula then pkgs.sddm-theme-dracula
            else if pkgs ? sddmThemes && pkgs.sddmThemes ? dracula then pkgs.sddmThemes.dracula
            else null;
          sddmDracula =
            if sddmDraculaRaw != null then
              pkgs.runCommand "sddm-theme-dracula-patched" { } ''
                cp -r ${sddmDraculaRaw} $out
                chmod -R u+w $out
                find $out -type f -exec \
                  sed -i "s|/nix/store/.*/bin/sddm-greeter|${greeterBin}|g" {} \;
              ''
            else null;
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
