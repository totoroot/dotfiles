{ lib
, buildNpmPackage
, cairo
, fetchurl
, makeWrapper
, nodejs_22
, pango
, pixman
, pkg-config
, stdenv
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.70.2";
  nodejs = nodejs_22;

  src = fetchurl {
    url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-bv+JqGQb0tIUXkm4B7f874y9VUzxlP/DHRq+DjYGddU=";
  };

  npmDepsHash = "sha256-TlR3rPGY9cs7tDbtYY6hpb0ckbbZ9Bm67jPHOjI2JyA=";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    cairo
    pango
    pixman
  ];

  dontPatchELF = stdenv.isDarwin;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    local packageDir="$out/lib/node_modules/${pname}"
    mkdir -p "$packageDir" "$out/bin"
    cp -r . "$packageDir"

    makeWrapper ${nodejs_22}/bin/node "$out/bin/pi-coding-agent" \
      --add-flags "$packageDir/dist/cli.js"
    ln -s "$out/bin/pi-coding-agent" "$out/bin/pi"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Interactive coding agent CLI from the Pi monorepo";
    homepage = "https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "pi-coding-agent";
  };
}
