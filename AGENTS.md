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
- `secrets/` — sops-nix secrets (never commit raw values)
- `overlays/` — package overlays for patching (e.g., darwin-patches.nix)
- `patches/` — patch files for upstream packages
- `docs/` — troubleshooting and reference docs
- `bin/` — helper scripts (check-overlays, rswitch)

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

## Pre-commit hooks

Repo uses `prek` with gitleaks for secret detection.

- Install: `nix develop --command prek install`
- Run hooks: `nix develop --command prek run`
- Hooks auto-install on clone via prek.toml

To bypass hook for emergency commits: `git commit --no-verify` (use sparingly).

## Existing repo direction

- The active targets are `jam` (NixOS server), `ATGRZMBP43`, and `thistle` (Darwin). Run `bin/check-fleet` before committing shared module or lockfile changes. Leave dormant hosts out of this gate. See [active-host operations](docs/active-hosts.md).
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

## File management rules

- **Do not delete files or revert changes unless explicitly instructed to do so.**
- If asked to remove something specific (e.g., "remove the aprutil patch"), only remove that exact thing. Preserve all other work — documentation, helpers, scripts, overlays — even if not immediately active.
- If unsure what to remove, ask: "Do you want me to remove X and keep Y, or remove everything related to X?"
- When cleaning up test/temporary changes, restore to clean state, not to empty state.

## Change safety and verification

- **Inspect destructive side effects before running or recommending activation.** Check cleanup/zap, file replacement, and migrations. Compare installed Homebrew casks with evaluated declarations and inspect removal stanzas. Rebuild approval is not approval to delete application data or silently change cleanup policy.
- **Protect mutable data.** Nix rollback does not restore profiles or databases. Before migration, identify the actual active executable/profile, close the application, and back up source, destination, and selection metadata. Verify contents and relevant data dates. Recover into a separate directory and preserve originals.
- **Check prior evidence before repeating fixes.** Read relevant git history, repo docs, and previous sessions under `~/.pi/agent/sessions/`. Distinguish confirmed working fixes from unsuccessful experiments.
- **Verify deployment and behavior, not just builds.** Check evaluation, activation, the running application's selected data, and the user-visible result separately. A fresh profile or surviving process is not proof of recovery. Report exactly what changed, what was verified, and what remains unknown.
- **Respect access and recovery boundaries.** Run available local read-only diagnostics directly and explain access limitations. Remote administration requires explicit authorization for the host and action. During suspected data loss, stop rebuilds, cleanup, and unnecessary writes. Search read-only and do not infer permanent loss from an incomplete search.

## Working style in this repo

- Inspect existing modules before creating new ones.
- Keep changes minimal and targeted.
- Never commit plaintext secrets. Use exactly one SOPS-encrypted file per host, `secrets/<host>.yaml`. Do not create separate files for new services or credentials.
- The owner edits the existing SOPS file on the corresponding host (for example, `secrets/jam.yaml` on jam). Add only the Nix wiring and tell the owner which keys to add. Do not edit the encrypted file or copy host decryption keys off the host.
- Follow the [host secret provisioning runbook](docs/secret-provisioning.md). Use Vaultwarden for the recovery copy of service credentials and the pinned `nix develop '.#secrets'` shell on either Mac. `bin/provision-host-secret` is dry-run only: it verifies Vaultwarden access and sends an encrypted dummy payload, not a real credential. Do not automate vault writes, secret changes, or deployment through the dry run.
- For packaging changes, ensure package is both defined and consumed correctly.
- For service changes, check related host wiring, proxying, secrets, and monitoring implications.
- Darwin shared config lives in `hosts/darwin/modules/`, and shared Darwin Home Manager defaults live in `home/modules/darwin-common.nix`.
- When changing Darwin hosts, prefer updating shared modules for cross-host behavior and keep only machine-specific launchd, Homebrew, package, and user settings in host-local files.
- Host-local Darwin `brew.nix` files must stay imported from the host `configuration.nix`/main nix-darwin module so nix-darwin sees host-specific Homebrew entries.
- Before rebuilding a Darwin host with Homebrew cleanup enabled, verify the evaluated lists are populated: `nix eval .#darwinConfigurations.<host>.config.homebrew.brews` and `nix eval .#darwinConfigurations.<host>.config.homebrew.casks`.
- **Commit straightforward, low-risk fixes directly.** If a fix is only a few lines and targeted verification gives high confidence, make an atomic local commit without asking for separate approval. Inform the user before committing, explain the scope, and exclude unrelated changes. Leave uncertain or higher-risk changes for review unless asked to commit them.
- **Commit `flake.lock` whenever it is modified.** Run `bin/check-fleet` first, then commit only `flake.lock` in a separate local commit titled `chore(flake): update locked inputs`.
- **Never push. User pushes manually.** A local commit does not authorize deployment.
