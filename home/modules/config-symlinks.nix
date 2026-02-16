{ config, lib, ... }:

with lib;
with lib.my;

let
  cfg = config.modules.home.configSymlinks;

  mkEntry = set: relativePath: {
    name = "${set.destination}/${relativePath}";
    value = {
      source =
        config.lib.file.mkOutOfStoreSymlink "${set.sourceDir}/${relativePath}";
      force = set.force;
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

    sets = mkOption {
      type = with types; listOf (submodule ({ ... }: {
        options = {
          sourceDir = mkOpt types.str configDir;
          destination = mkOpt types.str ".config";
          entries = mkOpt (listOf types.str) [ ];
          force = mkOpt types.bool false;
        };
      }));
      default = [ ];
      description = "Multiple config symlink sets with independent destinations.";
    };
  };

  config = mkIf cfg.enable {
    home.file =
      if cfg.sets != [ ]
      then
        builtins.listToAttrs (lib.flatten (map (set: map (mkEntry set) set.entries) cfg.sets))
      else
        builtins.listToAttrs (map (mkEntry cfg) cfg.entries);
  };
}
