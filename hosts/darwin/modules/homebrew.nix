{ config, lib, ... }:

{
  homebrew.enable = true;
  homebrew.onActivation = {
    # Install declared packages on activation, but review upgrades separately.
    autoUpdate = false;
    upgrade = false;
    # Zap can remove application data, including Firefox profiles.
    cleanup = "none";
    extraFlags = [ "--force" ];
  };
  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;

  environment.variables = {
    HOMEBREW_NO_UPDATE_REPORT_FORMULAE = "TRUE";
    HOMEBREW_NO_UPDATE_REPORT_CASKS = "TRUE";
  };

  environment.systemPath = lib.mkAfter [
    "/opt/homebrew/bin"
  ];
}
