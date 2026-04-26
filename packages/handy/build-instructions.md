# Handy Nix build notes

This package builds Handy from source for Linux and macOS/Darwin.

Upstream: <https://github.com/cjpais/Handy>
Version packaged here: `0.8.2`

## macOS/Darwin fix

Handy compiles a Swift bridge from `src-tauri/build.rs` on `aarch64-darwin`.
The important upstream runtime fix is from `cjpais/Handy#1316`:

```text
swiftc -parse-as-library ...
```

Without `-parse-as-library`, `swiftc` treats a single Swift source file as a
script and emits a synthetic `_main` symbol into the object file. With nixpkgs'
Darwin linker, that Swift `_main` can be selected instead of Rust/Tauri's main,
so the resulting app exits immediately with status 0.

The local patch is `use-nix-swift.patch`. It includes that fix and also makes
the Swift bridge build work in the Nix sandbox.

## Additional Nix/Darwin changes needed

The upstream build script assumes Apple's developer tooling is available through
`xcrun`. In Nix builds we must use tools and paths from the Nix environment
instead:

1. Respect `SDKROOT` if set.
   - Falls back to `xcrun --sdk macosx --show-sdk-path` outside Nix.
2. Respect `SWIFTC` if set.
   - Falls back to `swiftc` outside Nix.
3. Invoke the selected Swift compiler directly.
   - Avoids `xcrun swiftc` in the sandbox.
4. Pass `-parse-as-library` to `swiftc`.
   - Fixes the stub-main/runtime exit issue.
5. Add Darwin build inputs:
   - `swift`
   - `cctools`
   - `makeBinaryWrapper`
6. Set the compiler environment:

```nix
env.SWIFTC = "${swift}/bin/swiftc";
```

7. Install the macOS bundle and CLI wrapper:

```text
$out/Applications/Handy.app
$out/bin/handy
```

8. Add an `onnxruntime` runtime search path to the app binary with
   `install_name_tool`.

## General packaging steps

The package also needs normal Tauri/Rust/frontend packaging work:

1. Fetch Handy tag `v0.8.2`.
2. Build Rust from `src-tauri` with `rustPlatform.buildRustPackage`.
3. Vendor Cargo dependencies with `cargoHash`.
4. Build frontend dependencies with `bun install` in a fixed-output derivation.
5. Remove the upstream `package.json` `postinstall` script.
6. Patch `tauri.conf.json` to avoid build-time updater/signing artifacts:
   - remove `build.beforeBuildCommand`
   - disable updater artifacts
   - disable macOS signing identity
   - disable hardened runtime
7. Use `rustPlatform.bindgenHook` for libclang/include-path setup.
   - This avoids manual `LIBCLANG_PATH`/`BINDGEN_EXTRA_CLANG_ARGS` wiring.
   - On Linux it also avoids accidentally pointing bindgen at the wrong libc
     output; the cc-wrapper-provided include paths include `libc.dev`.
8. Use `cargo-tauri.hook` to build the app bundle.
9. Disable checks; upstream tests are not wired for this package build.

## Linux-specific notes

Linux builds install the Tauri-generated Debian payload into `$out`.

Extra Linux fixes:

- Patch `libappindicator-sys` to load Nix's absolute
  `libayatana-appindicator3.so.1` path.
- Wrap the app with GTK/GStreamer/runtime environment:
  - `WEBKIT_DISABLE_DMABUF_RENDERER=1`
  - ALSA plugin path including PipeWire and ALSA plugins
  - `LD_LIBRARY_PATH` containing `vulkan-loader` and `onnxruntime`

## Known validation status

Validated on `aarch64-darwin`:

```sh
nix build .#packages.aarch64-darwin.handy --no-link
```

The output contains:

```text
$out/Applications/Handy.app
$out/bin/handy
```

The app binary has an `onnxruntime` rpath.

This package uses `rustPlatform.bindgenHook`, matching the cleaner approach from
nixpkgs packaging review, instead of manually setting libclang include paths.

Linux package evaluation works, but a full `x86_64-linux` build requires a Linux
builder. It cannot be completed locally from an `aarch64-darwin` machine unless a
trusted Linux builder/substitution setup is available.
