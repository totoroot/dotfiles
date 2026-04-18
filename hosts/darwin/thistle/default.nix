{ inputs, ... }:

let
  user = "mathym";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = { inherit user inputs; };
    users.${user} = import ./home.nix;
  };

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;
    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;
    # User owning the Homebrew prefix
    user = "mathym";
    # Optional: Declarative tap management
    # taps = {
    #   "homebrew/homebrew-core" = inputs.nix-homebrew.darwinModules.nix-homebrew.homebrew-core;
    #   "homebrew/homebrew-cask" = inputs.nix-homebrew.darwinModules.nix-homebrew.homebrew-cask;
    # };
    # # Fully declarative tap-management; taps can no longer be added imperatively with `brew tap`
    # mutableTaps = false;
  };
}
