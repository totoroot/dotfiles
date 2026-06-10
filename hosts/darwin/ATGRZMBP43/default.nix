{ inputs, ... }:

let
  user = "matthias.thym";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../modules/common.nix
    ../modules/containers.nix
    ../modules/homebrew.nix
    ./agent.nix
    ./configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = { inherit user inputs; };
    users.${user} = import ./home.nix;
  };
}
