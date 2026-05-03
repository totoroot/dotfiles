{ pkgs, fetchFromGitHub, nodejs-23_x, makeWrapper }:

let
  gondolinVersion = "0.8.0";
  gondolinSrc = fetchFromGitHub {
    owner = "earendil-works";
    repo = "gondolin";
    rev = "v${gondolinVersion}";
    hash = "sha256-0000000000000000000000000000000000000000"; # TODO: Update with real hash after first build
  };
  
in
pkgs.stdenv.mkDerivation rec {
  pname = "gondolin";
  version = gondolinVersion;
  
  src = gondolinSrc;
  
  nativeBuildInputs = [
    nodejs-23_x
  ];
  
  buildInputs = [
    makeWrapper
  ];
  
  buildPhase = ''
    runHook preBuild
    
    # Build the TypeScript package
    cd host
    npm install
    npm run build
    
    runHook postBuild
  '';
  
  installPhase = ''
    runHook preInstall
    
    # Install the built package
    mkdir -p $out/bin
    cp host/dist/bin/gondolin.js $out/bin/gondolin
    
    # Create wrapper that sets up the Node.js environment
    makeWrapper $out/bin/gondolin $out/bin/gondolin ''
      export NODE_PATH=${pkgs.nodejs_23}/lib/node_modules
      export PATH=${pkgs.nodejs_23}/bin:$PATH
    ''
    
    # Copy runtime dependencies
    mkdir -p $out/lib/node_modules
    cp -r host/node_modules $out/lib/node_modules
    
    runHook postInstall
  '';
  
  meta = with pkgs.lib; {
    description = "Alpine Linux sandbox for running untrusted code with controlled filesystem and network access";
    homepage = "https://github.com/earendil-works/gondolin";
    license = licenses.asl20;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "gondolin";
  };
}