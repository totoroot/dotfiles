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
  # Future patches will be added here
  # Example:
  # package-name = prev.package-name.overrideAttrs (old: {
  #   patches = (old.patches or []) ++ [
  #     ./patches/package-name-unbreak-darwin.patch
  #   ];
  #   NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
  # });
}