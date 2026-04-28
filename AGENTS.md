# Dotfiles repo

## Scope

Declarative config for:
- NixOS hosts
- macOS via nix-darwin + Home Manager
- Home Manager user environments
- homelab and public-facing services
- custom flake packages
- secrets via `sops-nix`

Mixed fleet: servers, desktops, laptops.

## Structure

- `flake.nix` — inputs, overlays, packages, NixOS/Darwin/Home Manager outputs
- `hosts/` — per-host configs for NixOS and Darwin
- `modules/` — reusable system and service modules
- `home/` — reusable Home Manager modules and bridge config
- `packages/` — custom flake packages
- `config/` — static config files and templates
- `lib/` — custom helpers

## Durable patterns

- Prefer declarative setup over manual state.
- Prefer reusable modules over host-local one-off config.
- Keep host-specific exceptions only when truly host-specific.
- Keep service config, secrets wiring, and reverse proxy behavior in repo.
- When adding custom packages, expose them through flake for target systems.
- Linux and Darwin both matter. Check system-specific availability.

## Build failures and package patches

When a Nix package build fails and the fix hasn't propagated to channels yet:

1. **Add patch file** to `overlays/patches/<package>-<reason>.patch`
2. **Uncomment in** `overlays/darwin-patches.nix` or add new overlay for the package
3. **Test**: `nix eval .#darwinConfigurations.ATGRZMBP43 --apply 'x: map toString x.pkgs.pkgs.<package>.patches'`
4. **Verify** patch appears in output

**Pattern for Darwin patches:**
```nix
pkg-name = prev.pkg-name.overrideAttrs (old: {
  patches = (old.patches or []) ++ [ ./patches/<name>.patch ];
  NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
});
```

**Troubleshooting:**
- Use `./bin/check-overlays <package>` to verify patch application
- Check `docs/overlays-troubleshoot.md` for debug commands
- If package vendored (e.g., gitFull), override top-level attribute

## Existing repo direction

- Broad service management already lives here: monitoring, auth, mail, web, CI/CD, deployment.
- Access control direction favors SSO and declarative policy over ad-hoc basic auth.
- Monitoring stack includes Gatus, Loki, Alloy, Grafana, and Prometheus.
- Mail stack, DNS-related identity work, and deliverability changes are managed from this repo.
- Static site hosting and deployment are managed declaratively.
- CI/CD and runner setup are repo concerns and should stay declarative where feasible.
- Darwin setup uses nix-darwin plus Home Manager, with some tooling split across Nix and Homebrew where needed.

## Collaboration rules

- User expects concrete, technically exact changes.
- Do not guess facts that depend on actual host or repo state. Verify.
- Preserve declarative structure whenever possible.
- Understand existing module and host structure before adding one-off fixes.
- Prefer modifying existing reusable module structure over patching a single host file, unless host-local behavior is intended.

## Working style in this repo

- Inspect existing modules before creating new ones.
- Keep changes minimal and targeted.
- Do not commit secrets.
- For packaging changes, ensure package is both defined and consumed correctly.
- For service changes, check related host wiring, proxying, secrets, and monitoring implications.
