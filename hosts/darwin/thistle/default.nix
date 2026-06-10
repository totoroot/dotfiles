{ inputs, ... }:

let
  user = "mathym";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../modules/common.nix
    ../modules/homebrew.nix
    ./configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = { inherit user inputs; };
    users.${user} = import ./home.nix;
  };
}
