{ config, lib, ... }:

with lib;
with lib.my;

let
  cfg = config.modules.home.configSymlinks;
  liveConfigDir = "${config.xdg.configHome}/dotfiles/config";

  mkEntry = relativePath: {
    name = "${cfg.destination}/${relativePath}";
    value = {
      source =
        config.lib.file.mkOutOfStoreSymlink "${cfg.sourceDir}/${relativePath}";
      force = cfg.force;
    };
  };

  listFilesRecursive = relativeDir: acc:
    lib.flatten (lib.mapAttrsToList
      (name: kind:
        let
          path = if acc == "" then name else "${acc}/${name}";
        in
        if kind == "regular" || kind == "symlink" then
          [ "${relativeDir}/${path}" ]
        else if kind == "directory" then
          listFilesRecursive relativeDir path
        else
          [ ])
      (builtins.readDir "${cfg.sourceDir}/${if acc == "" then relativeDir else "${relativeDir}/${acc}"}"));
in
{
  options.modules.home.configSymlinks = {
    enable = mkBoolOpt false;

    sourceDir = mkOpt types.str liveConfigDir;

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

    recursiveEntries = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = ''
        Relative directory paths (from sourceDir / destination) that should be
        linked recursively into the user's home directory.
      '';
      example = [
        "micro/colorschemes"
      ];
    };

    force = mkOpt types.bool false;
  };

  config = mkIf (cfg.enable && (cfg.entries != [ ] || cfg.recursiveEntries != [ ])) {
    home.file = builtins.listToAttrs (
      (map mkEntry cfg.entries)
      ++ (lib.flatten (map (dir: map mkEntry (listFilesRecursive dir "")) cfg.recursiveEntries))
    );
  };
}
