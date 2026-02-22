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
      displayManager.sddm = {
        enable = true;
        extraPackages = let
          greeterBin =
            if pkgs ? sddm-unwrapped then "${pkgs.sddm-unwrapped}/bin/sddm-greeter"
            else "${pkgs.sddm}/bin/sddm-greeter";
          patchTheme = pkg:
            if pkg ? overrideAttrs then
              pkg.overrideAttrs (old: {
                postPatch = (old.postPatch or "") + ''
                  for f in $(find . -name theme.conf); do
                    sed -i "s|/nix/store/.*/bin/sddm-greeter|${greeterBin}|g" "$f"
                  done
                '';
              })
            else pkg;
          sddmDraculaRaw =
            if pkgs ? sddm-theme-dracula then pkgs.sddm-theme-dracula
            else if pkgs ? sddmThemes && pkgs.sddmThemes ? dracula then pkgs.sddmThemes.dracula
            else null;
          sddmDracula =
            if sddmDraculaRaw != null then patchTheme sddmDraculaRaw else null;
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
