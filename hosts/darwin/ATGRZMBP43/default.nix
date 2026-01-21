{ inputs, ... }:

let
  user = "matthias.thym";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = { inherit user; };
    users.${user} = import ./home.nix;
  };
}
