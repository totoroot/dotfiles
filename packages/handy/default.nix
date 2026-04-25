{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, cmake
, bun
, nodejs
, cargo-tauri
, jq
, llvmPackages
, writableTmpDirAsHomeHook
, makeBinaryWrapper
, symlinkJoin
, onnxruntime
, openssl
, cctools ? null
, swift ? null

  # Linux-only dependencies
, webkitgtk_4_1 ? null
, gtk3 ? null
, glib ? null
, libsoup_3 ? null
, alsa-lib ? null
, libayatana-appindicator ? null
, libevdev ? null
, libxtst ? null
, gtk-layer-shell ? null
, vulkan-loader ? null
, vulkan-headers ? null
, shaderc ? null
, gst_all_1 ? null
, glib-networking ? null
, libx11 ? null
, pipewire ? null
, alsa-plugins ? null
, wrapGAppsHook4 ? null
}:

rustPlatform.buildRustPackage (finalAttrs:
let
  gstPlugins = lib.optionals stdenv.hostPlatform.isLinux (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ]);

  frontendDeps = stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-frontend-deps";
    inherit (finalAttrs) version src;
    nativeBuildInputs = [ bun writableTmpDirAsHomeHook ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install --force --frozen-lockfile --ignore-scripts --no-progress
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -R node_modules $out/
      runHook postInstall
    '';
    dontFixup = true;
    outputHash = "sha256-AxE6WuFOGk40h+2w3Tyvnh64Eb5yHA5EZWgemYafRhg=";
    outputHashMode = "recursive";
  };
in
{
  pname = "handy";
  version = "0.8.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "cjpais";
    repo = "Handy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X21uFe609Vitv7yvFMfT847a4E2gy3Uy/uPh1I8D7pA=";
  };

  cargoRoot = "src-tauri";
  cargoHash = "sha256-qwcKuPfSLVmjIkduKkIRCmVk6BPbxF5htfY6f+6yV0w=";

  postPatch = ''
    ${jq}/bin/jq '
      del(.build.beforeBuildCommand) |
      .bundle.createUpdaterArtifacts = false |
      .bundle.macOS.signingIdentity = null |
      .bundle.macOS.hardenedRuntime = false
    ' src-tauri/tauri.conf.json > $TMPDIR/tauri.conf.json
    cp $TMPDIR/tauri.conf.json src-tauri/tauri.conf.json

    ${jq}/bin/jq 'del(.scripts.postinstall)' package.json > $TMPDIR/package.json
    cp $TMPDIR/package.json package.json

    # cbindgen calls `cargo metadata`, which fails in the Nix sandbox.
    find $cargoDepsCopy -path "*/ferrous-opencc-*/build.rs" \
      -exec sed -i \
        -e '/cbindgen::Builder::new/{:l;/write_to_file/!{N;bl};d}' \
        {} \;
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    find $cargoDepsCopy -path "*/libappindicator-sys-*/src/lib.rs" \
      -exec sed -i \
        's|libayatana-appindicator3.so.1|${libayatana-appindicator}/lib/libayatana-appindicator3.so.1|' \
        {} \;
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    patch -p1 < ${./use-nix-swift.patch}
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
    bun
    nodejs
    cargo-tauri.hook
    jq
    llvmPackages.libclang
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
    shaderc
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
    cctools
    swift
  ];

  buildInputs = [
    onnxruntime
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
    gtk3
    glib
    libsoup_3
    alsa-lib
    libayatana-appindicator
    libevdev
    libxtst
    gtk-layer-shell
    vulkan-loader
    vulkan-headers
    glib-networking
    libx11
  ]
  ++ gstPlugins;

  env = {
    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = lib.concatStringsSep " " ([
      "-isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion llvmPackages.libclang}/include"
    ] ++ lib.optional stdenv.hostPlatform.isLinux "-isystem ${stdenv.cc.libc.dev}/include");
    ORT_LIB_LOCATION = "${onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
    GST_PLUGIN_SYSTEM_PATH_1_0 = lib.optionalString stdenv.hostPlatform.isLinux (
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins
    );
    OPENSSL_NO_VENDOR = "1";
  } // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    SWIFTC = "${swift}/bin/swiftc";
  };

  preBuild = ''
    cp -R ${frontendDeps}/node_modules .
    chmod -R u+w node_modules
    patchShebangs node_modules
    export HOME=$TMPDIR
    bun run build
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mv src-tauri/target/${stdenv.hostPlatform.rust.rustcTarget}/release/bundle/deb/*/data/usr/* $out/
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications $out/bin
    mv src-tauri/target/${stdenv.hostPlatform.rust.rustcTarget}/release/bundle/macos/Handy.app \
      $out/Applications/
    makeWrapper "$out/Applications/Handy.app/Contents/MacOS/handy" "$out/bin/handy"
  ''
  + ''
    runHook postInstall
  '';

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      --set ALSA_PLUGIN_DIR "${symlinkJoin {
        name = "combined-alsa-plugins";
        paths = [
          "${pipewire}/lib/alsa-lib"
          "${alsa-plugins}/lib/alsa-lib"
        ];
      }}"
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ vulkan-loader onnxruntime ]}"
    )
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath ${onnxruntime}/lib \
      "$out/Applications/Handy.app/Contents/MacOS/handy"
  '';

  meta = {
    description = "Free, open source, offline speech-to-text application";
    homepage = "https://handy.computer";
    changelog = "https://github.com/cjpais/Handy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "handy";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
