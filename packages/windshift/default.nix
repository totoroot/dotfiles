{ lib
, fetchgit
, buildGo127Module
, buildNpmPackage
, nodejs_24
, git
}:

let
  pname = "windshift";
  version = "0.8.9";
  rev = "ed6124bc3686a30d440678878518e4d49f8d3976";

  src = fetchgit {
    url = "https://github.com/Windshiftapp/core.git";
    inherit rev;
    hash = "sha256-cRGysC7N0TMlwmIPKNt/CDL+Dmxn4tqw249aLbTzL/g=";
  };

  frontend = buildNpmPackage {
    pname = "${pname}-frontend";
    inherit version src;

    sourceRoot = "${src.name}/frontend";
    nodejs = nodejs_24;
    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-g+DFQdBxNrFSQq0rprmAApCaevcvk3EeIJejQIK0ZTo=";

    # Upstream pins exact Node/npm patch releases; nixpkgs patch differences
    # are acceptable for this frontend build.
    npmFlags = [ "--ignore-scripts" "--no-audit" "--no-fund" "--engine-strict=false" ];

    buildPhase = ''
      runHook preBuild
      npm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist $out/
      runHook postInstall
    '';

    meta.platforms = lib.platforms.all;
  };
in
buildGo127Module {
  inherit pname version src;

  vendorHash = "sha256-5GvviGtgPoofDXYrsUJrwOyfRG91l+YeT2Kc3BlYrlY=";
  subPackages = [ "." ];

  nativeBuildInputs = [ git ];

  env.CGO_ENABLED = 0;
  env.GOTOOLCHAIN = "local";

  preBuild = ''
    rm -rf frontend/dist
    mkdir -p frontend
    cp -r ${frontend}/dist frontend/dist
  '';

  ldflags = [
    "-s"
    "-w"
    "-X" "windshift/internal/version.Version=${version}"
    "-X" "windshift/internal/version.Commit=${rev}"
    "-X" "windshift/internal/version.Date=unknown"
    "-X" "windshift/internal/version.ReleaseName="
  ];

  meta = with lib; {
    description = "Self-hosted work management platform for teams";
    homepage = "https://github.com/Windshiftapp/core";
    license = licenses.agpl3Only;
    platforms = platforms.unix;
    mainProgram = "windshift";
  };
}
