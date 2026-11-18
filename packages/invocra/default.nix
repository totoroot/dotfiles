{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage {
  pname = "invocra";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "dsszs3333";
    repo = "invocra";
    rev = "1b5310561c7edb9073ced212a9e5c98e1b5f013c";
    hash = "sha256-cePdTeVoNChy8IFvSNu/VSvskzXiC1NePa0x0vA2hvI=";
  };

  cargoHash = "sha256-amOAQHNNoK+0T5vYtRhyvtvGIVpva4j58peVeipo/RM=";
  cargoBuildFlags = [ "--package" "invocra" ];
  cargoTestFlags = [ "--workspace" ];

  # HTTP client tests use local mock servers, not a real GitLab instance.
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Terminal dashboard for GitLab CI/CD pipelines";
    homepage = "https://github.com/dsszs3333/invocra";
    license = lib.licenses.mit;
    mainProgram = "invocra";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
