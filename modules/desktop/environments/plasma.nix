{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.environments.plasma;
in {
  options.modules.desktop.environments.plasma = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      # Display Manager for KDE Plasma
      displayManager.sddm = {
        # Make it rewritable in case Plasma should be installed
        # but other display manager should be used
        enable = mkDefault true;
        package = mkForce pkgs.sddm;
        extraPackages = let
          greeterBin =
            if pkgs ? sddm-unwrapped then "${pkgs.sddm-unwrapped}/bin/sddm-greeter"
            else "${pkgs.sddm}/bin/sddm-greeter";
          sddmDraculaRaw =
            if pkgs ? sddm-theme-dracula then pkgs.sddm-theme-dracula
            else if pkgs ? sddmThemes && pkgs.sddmThemes ? dracula then pkgs.sddmThemes.dracula
            else null;
          sddmDracula =
            if sddmDraculaRaw != null then
              pkgs.runCommand "sddm-theme-dracula-patched" { } ''
                cp -r ${sddmDraculaRaw} $out
                chmod -R u+w $out
                find $out -name theme.conf -exec \
                  sed -i "s|/nix/store/.*/bin/sddm-greeter|${greeterBin}|g" {} \;
              ''
            else null;
        in
        lib.optional (sddmDracula != null) sddmDracula;
        # Use Wayland Session by default
        wayland = {
          enable = mkDefault true;
          # Use KWin instead of weston
          compositor = "kwin";
        };
      };
      xserver.enable = true;
      # Enable KDE Plasma itself
      desktopManager.plasma6 = {
        enable = true;
      };
    };

    # Enable KDE connect for all Plasma desktops
    programs.kdeconnect.enable = true;

    # Exclude unnecessary KDE packages
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      gwenview
      okular
      oxygen
      khelpcenter
    ];

    environment.systemPackages = with pkgs.kdePackages; [
      # Calculator
      kcalc
      # Color picker
      kcolorchooser
      # KWin script for ultrawide layouts
      kzones
    ];
  };
}
