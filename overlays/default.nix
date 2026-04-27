# Overlays for Darwin patches and compatibility fixes
# Use: self.overlays.darwin-patches in pkgs imports

{
  darwin-patches = import ./darwin-patches.nix;
}