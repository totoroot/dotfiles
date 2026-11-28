# Configured machines only. Standalone Home Manager profiles live in linux/.
# Only active machines are evaluated by bin/check-fleet.
{
  nixosConfigurations = {
    jam = { path = ./nixos/jam; active = true; };
    grape = { path = ./nixos/grape; active = false; };
    mulberry = { path = ./nixos/mulberry; active = false; };
    purple = { path = ./nixos/purple; active = false; };
    raspberry = { path = ./nixos/raspberry; active = false; };
    sangria = { path = ./nixos/sangria; active = false; };
    violet = { path = ./nixos/violet; active = false; };
  };

  darwinConfigurations = {
    ATGRZMBP43 = { path = ./darwin/ATGRZMBP43; active = true; };
    thistle = { path = ./darwin/thistle; active = true; };
  };
}
