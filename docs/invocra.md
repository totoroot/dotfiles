# Invocra: read-only GitLab pipeline dashboard

## Package

- Defined in `packages/invocra/default.nix` and exposed through the flake packages.
- Version 0.2.2, pinned to commit `1b5310561c7edb9073ced212a9e5c98e1b5f013c`.
- Source and Cargo dependency hashes are fixed. Updating flake inputs does not update Invocra's source version.
- Included only in `hosts/darwin/ATGRZMBP43/packages.nix`.
- No Homebrew tap, background service, automatic login, or GitLab credentials are configured.

## First use

1. Create a separate, short-lived GitLab token with **only `read_api`**. Do not reuse a write-capable token from `glab` or another tool.
2. Prefer a project access token when monitoring one project. A personal access token can read everything its user and scope permit, including sensitive CI information.
3. Run `invocra` and complete setup with the trusted HTTPS GitLab URL and that read-only token. Use `read_api` even if the wizard suggests `api`.
4. Let Invocra store credentials in macOS Keychain. Do not set `INVOCRA_GITLAB_TOKEN`, which is reused for every configured instance.
5. Select the projects/groups to monitor. Configuration and offline metadata are stored under `~/.config/invocra/`.

Read-only access is enforced by GitLab token permissions, not by a special Invocra build. Write controls may still appear in the UI, but GitLab must reject those operations for a `read_api` token. Do not grant `api` or `write_repository` to make a dashboard operation work.

Do not put tokens in Nix expressions, shell startup files, command arguments, or Git. Do not grant extra Full Disk Access or run Invocra with sudo. Keychain storage is not a sandbox for the application.

## Updates and removal

Review upstream changes before changing the pinned source commit or dependency hash. Preserve `~/.config/invocra/` and the Keychain entries when removing the package unless credential revocation and data removal are explicitly intended.
