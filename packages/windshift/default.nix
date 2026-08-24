{ lib
, fetchgit
, buildGoModule
, buildNpmPackage
, nodejs_24
, git
}:

let
  pname = "windshift";
  version = "0.8.6-7";
  rev = "10512c09d893fb4f73f442985f4032c046144b41";

  src = fetchgit {
    url = "https://github.com/Windshiftapp/core.git";
    inherit rev;
    hash = "sha256-PS0QE++Q3s8jproy9X50nvUjTTRYS1ggNzOTJWrG7IQ=";
  };

  frontend = buildNpmPackage {
    pname = "${pname}-frontend";
    inherit version src;

    sourceRoot = "${src.name}/frontend";
    nodejs = nodejs_24;
    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-g5nW0lq/0AUNUbyaEt/BFolEHoroihuam47DL831Cy0=";

    # nixpkgs currently supplies Node 24.19/npm 11.17, while upstream pins
    # 24.18/11.16 exactly. The patch-level difference is acceptable here.
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
buildGoModule {
  inherit pname version src;

  vendorHash = "sha256-nni0FAx+dD+6cBy4hVYt48HtED/JLkbBUl+QaDEOPRI=";
  subPackages = [ "." ];

  nativeBuildInputs = [ git ];

  env.CGO_ENABLED = 0;
  env.GOTOOLCHAIN = "local";

  # nixpkgs currently provides Go 1.26.5 while upstream requires the 1.26.6
  # patch release. The module sources do not rely on a patch-release feature.
  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.26.6" "go 1.26.5"
  '';

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
