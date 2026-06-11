{ config, lib, ... }:

{
  homebrew.enable = true;
  homebrew.onActivation = {
    autoUpdate = true;
    upgrade = true;
    cleanup = "zap";
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
