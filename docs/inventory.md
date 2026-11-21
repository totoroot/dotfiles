# Infrastructure inventory

This is the index of hosts, retained configurations, and managed resources. **Active** means supported by `bin/check-fleet`, not necessarily online at the time of reading. **Dormant** means retained for reference and outside the evaluation gate. For deployment and verification, see [Active-host operations](active-hosts.md).

## Active hosts

| Host | Platform and role | Configuration | Operations |
| --- | --- | --- | --- |
| `jam` | NixOS on a Netcup VPS in Germany. Hosts web, mail, Nextcloud, Vaultwarden, PostgreSQL, and monitoring. | [`nixosConfigurations.jam`](../hosts/nixos/jam/default.nix) | [Deploy and verify](active-hosts.md#jam-switch-boot-and-service-checks), [backup and recovery](jam-backups.md) |
| `ATGRZMBP43` | Apple Silicon Mac workstation. Managed by nix-darwin and Home Manager. | [`darwinConfigurations.ATGRZMBP43`](../hosts/darwin/ATGRZMBP43/default.nix) | [macOS operations](active-hosts.md#macos-configuration-and-package-upgrades) |
| `thistle` | Apple Silicon Mac. Managed by nix-darwin and Home Manager. | [`darwinConfigurations.thistle`](../hosts/darwin/thistle/default.nix) | [macOS operations](active-hosts.md#macos-configuration-and-package-upgrades) |

## Dormant NixOS hosts

| Host | Last documented role or hardware | Host notes |
| --- | --- | --- |
| `grape` | Lenovo ThinkPad T470 notebook | [grape](../hosts/nixos/grape/README.md) |
| `mulberry` | Raspberry Pi 3B+ | [mulberry](../hosts/nixos/mulberry/README.md) |
| `purple` | Workstation and NixOS build machine | [purple](../hosts/nixos/purple/README.md) |
| `raspberry` | Raspberry Pi 3B+ | [raspberry](../hosts/nixos/raspberry/README.md) |
| `sangria` | 2010 Mac mini running NixOS | [sangria](../hosts/nixos/sangria/README.md) |
| `violet` | Home server, currently offline. Candidate for a second backup destination, not in use for jam's backups. | [violet](../hosts/nixos/violet/README.md) |

`personal` appears in the flake's NixOS output list but is a [shared settings module](../hosts/nixos/personal.nix), not a machine. The [Debian](../hosts/linux/debian/home.nix) and [Steam Deck](../hosts/linux/steamdeck/home.nix) Home Manager profiles are retained configurations, not active hosts. The `homeConfigurations` output currently fails to evaluate because the Linux profile import is missing its `nixpkgs` argument. Plan a fresh Steam Deck setup rather than an in-place upgrade.

## Managed resources

| Resource | Provider and location | Purpose | Setup and operations |
| --- | --- | --- | --- |
| `pantry` | Hetzner Storage Box BX11, Falkenstein, Germany | Off-host Restic storage for `jam`. A PostgreSQL snapshot has been retrieved and verified. Nightly uploads are running. | [Storage Box setup](pantry.md), [Jam backup and recovery](jam-backups.md) |

## Maintaining this inventory

- When adding or retiring a machine or managed resource, update its inventory entry alongside the configuration. Record its role, lifecycle status, platform or provider, dependencies, and links to configuration and operations.
- Keep host-specific hardware, deployment, and recovery details with the host or resource. Record what was actually verified and label planned work or unconfirmed details as such.
- Keep credentials and recovery material out of Git. Document how access is managed without including passwords, private keys, tokens, or recovery codes.
