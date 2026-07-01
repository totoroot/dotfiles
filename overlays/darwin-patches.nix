# Darwin package patches overlay
# Fixes build failures and compatibility issues on macOS
#
# To add a patch for a package:
# 1. Create patch file in ./patches/<package>-<reason>-<platform>.patch
# 2. Add package override in this file
# 3. Test with: nix eval .#darwinConfigurations.ATGRZMBP43 --apply 'x: map toString x.pkgs.pkgs.<package>.patches'

final: prev:
let
  inherit (prev) lib;
in
{
  podman = prev.podman.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      platforms = (old.meta.platforms or [ ]) ++ [ "aarch64-darwin" ];
    };
  });
}
