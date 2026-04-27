# Patches

Patches in this directory override upstream Nix packages to fix build failures, add flags, or unbreak Darwin compatibility.

## Naming

Format: `<package>-<reason>-<platform>.patch`

Examples:
- `aprutil-unbreak-darwin.patch` — fixes apr-util on macOS
- `openssl-fix-flags-linux.patch` — fixes OpenSSL build on Linux

## Adding a patch

1. Create patch file in this directory
2. Add overlay in `overlays/darwin-patches.nix` (for Darwin) or `lib/mkPlatformPkgs.nix`
3. Test with: `./bin/check-overlays <package>`
4. Verify: `nix eval --raw .#darwinConfigurations.ATGRZMBP43 --apply 'x: map toString x.pkgs.pkgs.<package>.patches'`

## Common patterns

```nix
# Override package with patch + C flags
pkg = prev.pkg.overrideAttrs (old: {
  patches = (old.patches or []) ++ [ ./patches/<name>.patch ];
  NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
});
```

## Troubleshooting

- **Patch not applying?** Check system string matches (`aarch64-darwin` vs `x86_64-linux`)
- **Package vendored?** Override top-level attribute (e.g., `gitFull` not `apr-util`)
- **Build fails after patch?** Add `NIX_CFLAGS_COMPILE` with `-std=gnu17`