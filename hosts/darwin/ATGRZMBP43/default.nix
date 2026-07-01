{ inputs, ... }:

let
  user = "matthias.thym";
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
    sharedModules = [
      {
        nixpkgs = {
          config = {
            allowUnfree = true;
            allowUnsupportedSystem = true;
          };
          overlays = [
            inputs.self.overlay
            inputs.self.overlays.darwin-patches
          ];
        };
      }
    ];
    users.${user} = import ./home.nix;
  };

  nix-homebrew = {
    enable = true;
    autoMigrate = true;
    enableRosetta = true;
    user = user;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };
}
