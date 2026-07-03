{ lib
, stdenvNoCC
, fetchFromGitHub
, nodejs_22
, python3
, makeWrapper
}:

stdenvNoCC.mkDerivation rec {
  pname = "beautiful-mermaid";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "lukilabs";
    repo = pname;
    rev = "main";
    hash = "sha256-hjWlvqlMjkmml9AnS1pWMLIp3SdxhBrieAYhKWrA+MQ=";
  };

  nativeBuildInputs = [ nodejs_22 python3 makeWrapper ];

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    export npm_config_strict_ssl=false

    ${python3}/bin/python3 - <<'PY'
import json
with open('package.json') as f:
    pkg = json.load(f)
pkg.get('devDependencies', {}).pop('@types/bun', None)
with open('package.json', 'w') as f:
    json.dump(pkg, f, indent=2)
    f.write('\n')

with open('tsconfig.json') as f:
    ts = json.load(f)
ts.get('compilerOptions', {}).pop('types', None)
with open('tsconfig.json', 'w') as f:
    json.dump(ts, f, indent=2)
    f.write('\n')
PY

    npm install --ignore-scripts --no-audit --no-fund
    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    local packageDir="$out/lib/node_modules/${pname}"
    mkdir -p "$packageDir" "$out/bin"
    cp -r dist node_modules package.json README.md LICENSE "$packageDir/"
    cp ${./ascii-cli.mjs} "$packageDir/ascii-cli.mjs"

    makeWrapper ${nodejs_22}/bin/node "$out/bin/beautiful-mermaid-ascii" \
      --run 'export NODE_PATH="$packageDir/node_modules"' \
      --add-flags "$packageDir/ascii-cli.mjs"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Render Mermaid diagrams as beautiful SVGs or ASCII art";
    homepage = "https://github.com/lukilabs/beautiful-mermaid";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
