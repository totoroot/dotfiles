# Overlay Troubleshooting

Quick reference for Darwin package overlay issues.

## Check Patch Application

```bash
# Show all patches for a package
nix eval .#darwinConfigurations.ATGRZMBP43 \
  --apply 'x: map toString x.pkgs.pkgs.aprutil.patches'

# Pretty print JSON
nix eval .#darwinConfigurations.ATGRZMBP43 \
  --apply 'x: builtins.toJSON (map toString x.pkgs.pkgs.aprutil.patches)' | jq
```

## Verify Overlay Exists

```bash
# Check darwin-patches overlay is loaded
nix eval .#overlays --json | jq 'keys'

# Confirm pkgsDarwin has patches
nix eval .#darwinConfigurations.ATGRZMBP43 \
  --apply 'x: x.pkgs.stdenv.isDarwin'
```

## Common Issues

### 1. Patch not in list

**Symptom:** Your local patch path missing from output.

**Causes:**
- System triple mismatch (`aarch64-darwin` vs `x86_64-linux`)
- Wrong attribute name (use `aprutil`, not `apr-util`)
- Package vendored inside another (override `gitFull`, not `apr-util`)
- Overlay ordering (repo overlays not appended)

**Fix:**
```nix
# Verify system and overlay order in flake.nix
pkgsDarwin = import inputs.nixpkgs {
  system = "aarch64-darwin";
  config.allowUnfree = true;
  overlays = [
    (import ./overlays/darwin-patches.nix)  # must be before self.overlays
  ] ++ (attrValues self.overlays);
};
```

### 2. Build fails after patch

**Fix:** Add C17 standard flag:

```nix
NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
```

### 3. Package vendored

**Symptom:** `attribute 'apr-util' missing`, `Did you mean aprutil?`

**Fix:** Override top-level attribute:

```nix
gitFull = prev.gitFull.overrideAttrs (old: {
  apr-util = prev.apr-util.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./patches/aprutil-unbreak-darwin.patch ];
  });
});
```

## Debug Commands

```bash
# Find which pkgs instance darwin-rebuild uses
nix eval --raw .#darwinConfigurations.ATGRZMBP43.pkgs.config.allowUnfree

# Inspect build log
nix log /nix/store/*-aprutil-1.6.3.drv

# Build single package
nix build .#darwinConfigurations.ATGRZMBP43.pkgs.aprutil --no-link

# Check overlay position in attr chain
nix eval .#darwinConfigurations.ATGRZMBP43 \
  --apply 'x: builtins.map toString (attrValues x.pkgs.pkgs)'
```

## Quick Check Script

```bash
./bin/check-overlays aprutil
```