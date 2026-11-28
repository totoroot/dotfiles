# Dotfiles

Declarative configuration for a personal Nix fleet: NixOS, nix-darwin, Home Manager, homelab services, and custom packages. This is not a turnkey installer. Adapt host names, users, disks, domains, and secrets before reuse.

[Browse on Codeberg](https://codeberg.org/totoroot/dotfiles)

## Start here

| I want to… | Go to |
| --- | --- |
| Find a machine or managed resource | [Infrastructure inventory](docs/inventory.md) |
| Deploy or verify `jam`, `ATGRZMBP43`, or `thistle` | [Active-host operations](docs/active-hosts.md) |
| Set up a machine | [NixOS setup](hosts/nixos/README.md) · [Darwin bootstrap](hosts/darwin/README.md) |
| Provision a service credential | [Host secret provisioning](docs/secret-provisioning.md) |
| Find an operational helper | [Script index](bin/README.md) |
| Work on backups or monitoring | [Jam backups](docs/jam-backups.md) · [Monitoring](docs/monitoring.md) |
| Find cache, remote builder, or Headscale notes | [Infrastructure notes](docs/infrastructure.md) |

## Repository map

| Path | What lives here |
| --- | --- |
| `flake.nix`, `hosts/registry.nix` | Inputs and outputs, and the list of configured machines and their support status |
| `hosts/nixos/`, `hosts/darwin/`, `hosts/linux/` | NixOS hosts, nix-darwin hosts, and standalone Home Manager profiles |
| `modules/`, `hosts/darwin/modules/`, `home/` | Reusable system, Darwin, and Home Manager modules |
| `packages/`, `overlays/`, `config/`, `lib/` | Custom packages, overrides, static files, and Nix helpers |
| `docs/`, `bin/`, `tests/`, `secrets/` | Runbooks, scripts, tests, and SOPS-encrypted host files |

To list outputs without forcing every retained configuration to evaluate:

```sh
nix eval .#nixosConfigurations --apply builtins.attrNames
nix eval .#darwinConfigurations --apply builtins.attrNames
nix eval .#homeConfigurations --apply builtins.attrNames
```

## Validate changes

```sh
nix develop --command prek install  # once per checkout
nix develop --command prek run      # check staged changes
bin/check-fleet                     # required for shared Nix or lockfile changes
```

The fleet check evaluates the active machines without building or activating them. Dormant configurations do not block updates. See [AGENTS.md](AGENTS.md) for repo conventions and change safety.
