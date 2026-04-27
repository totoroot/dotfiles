# mkPlatformPkgs — create pkgs instance with overlays for a given system
#
# Usage:
#   let pkgsDarwin = mkPlatformPkgs { system = "aarch64-darwin"; inputs = inputs; };
#   in darwinConfigurations.myhost = { pkgs = pkgsDarwin; ... }
#
# Arguments:
#   system       — system triple (e.g., "aarch64-darwin", "x86_64-linux")
#   inputs       — flake inputs (needed for nixpkgs)
#   extraOverlays — list of overlays to apply before repo overlays (optional)
#
# Returns:
#   A pkgs instance with:
#   - allowUnfree = true
#   - darwin-patches overlay (if darwin system)
#   - all overlays from ./overlays/

{ system, inputs, extraOverlays ? [ ] }:

let
  inherit (builtins) attrValues;
in
import inputs.nixpkgs {
  inherit system;
  config.allowUnfree = true;
  overlays = extraOverlays ++ (attrValues self.overlays);
}