{ config, inputs, ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/containers.nix
    ../modules/home-manager.nix
    ../modules/homebrew.nix
    ./configuration.nix
  ];

  home-manager.users.${config.system.primaryUser} = import ./home.nix;
  nix-homebrew.taps."datadog-labs/homebrew-pack" = inputs.datadog-homebrew-pack;
}
