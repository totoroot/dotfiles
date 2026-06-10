{ lib, ... }:

{
  homebrew.enable = true;
  homebrew.onActivation = {
    autoUpdate = true;
    upgrade = true;
    cleanup = "zap";
    extraFlags = [ "--force" ];
    extraEnv = {
      HOMEBREW_NO_INSTALL_FROM_API = "1";
    };
  };
  homebrew.taps = [];

  environment.variables = {
    HOMEBREW_NO_UPDATE_REPORT_FORMULAE = "TRUE";
    HOMEBREW_NO_UPDATE_REPORT_CASKS = "TRUE";
    HOMEBREW_NO_INSTALL_FROM_API = "1";
  };

  environment.systemPath = lib.mkAfter [
    "/opt/homebrew/bin"
  ];
}
