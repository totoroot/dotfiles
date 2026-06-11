{ inputs, ... }:

let
  user = "mathym";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ../modules/common.nix
    ../modules/containers.nix
    ../modules/homebrew.nix
    ./configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = { inherit user inputs; };
    users.${user} = import ./home.nix;
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = user;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };
}
