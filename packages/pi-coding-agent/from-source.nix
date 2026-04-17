{ lib
, buildNpmPackage
, cairo
, fetchFromGitHub
, makeWrapper
, nodejs_22
, pango
, pixman
, pkg-config
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.67.6";
  nodejs = nodejs_22;

  src = fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-mono";
    rev = "v${version}";
    hash = "sha256-e9wQlGzveYrY4BWpRq1xq2PYjn5ZK7/hdnWgx7DMkLA=";
  };

  npmDepsHash = "sha256-wH/eN20rOLGujWY+YTRul/AEq9Ta9/kA5GU0PmiDYM8=";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    cairo
    pango
    pixman
  ];

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    local packageDir="$out/lib/node_modules/${pname}"
    mkdir -p "$packageDir" "$out/bin"
    cp -r packages/coding-agent/dist "$packageDir/"
    cp -r packages/coding-agent/docs "$packageDir/"
    cp -r packages/coding-agent/examples "$packageDir/"
    cp packages/coding-agent/package.json "$packageDir/"
    cp packages/coding-agent/README.md "$packageDir/"
    cp packages/coding-agent/CHANGELOG.md "$packageDir/"

    makeWrapper ${nodejs_22}/bin/node "$out/bin/pi" \
      --add-flags "$packageDir/dist/cli.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Interactive coding agent CLI from the Pi monorepo (source build reference)";
    homepage = "https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "pi";
  };
}
