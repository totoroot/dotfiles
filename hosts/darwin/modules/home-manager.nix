{ config, inputs, ... }:

let
  user = config.system.primaryUser;
in
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

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
  };
}
