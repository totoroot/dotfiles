{ config, lib, ... }:

with lib;
with lib.my;

let
  cfg = config.modules.home.configSymlinks;

  mkEntry = relativePath: {
    name = "${cfg.destination}/${relativePath}";
    value = {
      source =
        config.lib.file.mkOutOfStoreSymlink "${cfg.sourceDir}/${relativePath}";
      force = cfg.force;
      recursive = true;
    };
  };
in
{
  options.modules.home.configSymlinks = {
    enable = mkBoolOpt false;

    sourceDir = mkOpt types.str configDir;

    destination = mkOpt types.str ".config";

    entries = mkOption {
      type = with types; listOf types.str;
      default = [ ];
      description = ''
        Relative paths (from sourceDir / destination) that should be linked into
        the user's home directory.
      '';
      example = [
        "micro/settings.json"
        "kitty/kitty.conf"
      ];
    };

    force = mkOpt types.bool false;
  };

  config = mkIf (cfg.enable && cfg.entries != [ ]) {
    home.file = builtins.listToAttrs (map mkEntry cfg.entries);
  };
}
