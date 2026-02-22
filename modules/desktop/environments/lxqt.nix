{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.environments.lxqt;
in {
  options.modules.desktop.environments.lxqt = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
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
        enable = true;
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
      };
      xserver = {
        displayManager.lightdm.enable = false;
        enable = true;
        # Display Manager for LXQt
        # Enable LXQt itself
        desktopManager.lxqt.enable = true;
      };
      connman.enable = true;
    };
    # Exclude unnecessary LXQt packages
    environment.lxqt.excludePackages = with pkgs.lxqt; [
    ];
    xdg.portal.lxqt.enable = true;
    programs.nm-applet.enable = true;
  };
}
