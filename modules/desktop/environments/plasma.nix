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
      displayManager.sddm = let
        sddmBase = pkgs.kdePackages.sddm;
        sddmWithGreeter = pkgs.runCommand "sddm-with-greeter" { } ''
          cp -r ${sddmBase} $out
          chmod -R u+w $out
          if [ ! -x "$out/bin/sddm-greeter" ]; then
            for candidate in "$out/libexec/sddm-greeter" "$out/lib/sddm/sddm-greeter"; do
              if [ -x "$candidate" ]; then
                ln -s "$candidate" "$out/bin/sddm-greeter"
                break
              fi
            done
          fi
        '';
      in {
        # Make it rewritable in case Plasma should be installed
        # but other display manager should be used
        enable = mkDefault true;
        package = mkForce sddmWithGreeter;
        extraPackages = let
          greeterBin = "${sddmWithGreeter}/bin/sddm-greeter";
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
