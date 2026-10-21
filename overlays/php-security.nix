{ inputs }:

final: _prev:
let
  # Keep PHP and its extensions together without upgrading the system package set.
  # Remove this overlay once the regular nixpkgs inputs include PHP 8.4.27 or newer.
  patchedPkgs = import inputs.nixpkgs-php {
    system = final.stdenv.hostPlatform.system;
  };
in
{
  php84 = patchedPkgs.php84;
  php = patchedPkgs.php84;
}
