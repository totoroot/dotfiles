{ config, lib, ... }:

with lib;
let
  cfg = config.modules.nix.gc;
in
{
  options.modules.nix.gc = {
    enable = mkEnableOption "automatic nix store garbage collection and optimisation" // {
      default = true;
    };

    dates = mkOption {
      type = types.str;
      default = "daily";
      description = "Systemd calendar/timer expression for automatic garbage collection.";
    };

    options = mkOption {
      type = types.str;
      default = "--delete-older-than 7d";
      description = "Arguments passed to nix-collect-garbage.";
    };

    autoOptimiseStore = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic store deduplication to reduce disk usage.";
    };
  };

  config = mkIf cfg.enable {
    nix = {
      gc = {
        automatic = true;
        dates = cfg.dates;
        options = cfg.options;
      };
      settings.auto-optimise-store = mkDefault cfg.autoOptimiseStore;
    };
  };
}
