# Dotfiles

Declarative configuration for my personal Nix fleet: NixOS hosts, macOS via
nix-darwin, Home Manager environments, homelab services, public-facing services,
custom packages, and secrets wiring.

<a href="https://codeberg.org/totoroot/dotfiles">
  <img alt="Get it on Codeberg" src="https://get-it-on.codeberg.org/get-it-on-blue-on-white.png" height="88">
</a>

## Scope

This repository manages:

- NixOS desktops, laptops, servers, and small devices
- macOS hosts through nix-darwin + Home Manager
- Generic Linux Home Manager profiles
- Homelab services, reverse proxies, monitoring, mail, SSO, and deployment bits
- Secrets through `sops-nix`
- Custom flake packages

This is a personal configuration, not a turnkey installer. Reuse pieces, but
expect to adapt host names, disks, users, secrets, domains, and service choices.

## Supported hosts

- `jam`: active NixOS server. Prefer targeted security updates over broad input refreshes.
- `ATGRZMBP43` and `thistle`: active macOS hosts, primarily managed with Home Manager.
- Other configurations are dormant and retained for reference. They do not block updates. Plan a fresh setup for Steam Deck.

Run `bin/check-fleet` before committing shared module or lockfile changes. It
evaluates the three active targets without building or activating them. See
[active-host operations](docs/active-hosts.md) for build, boot, and service checks.
The [infrastructure inventory](docs/inventory.md) lists active and dormant hosts
and managed resources such as the `pantry` backup destination.

## Layout

| Path | Purpose |
| --- | --- |
| `flake.nix` | Inputs, overlays, packages, modules, and host outputs |
| `hosts/nixos/` | NixOS host configs |
| `hosts/darwin/` | macOS / nix-darwin host configs |
| `hosts/linux/` | Generic Linux Home Manager profiles |
| `modules/` | Reusable NixOS and system modules |
| `home/` | Reusable Home Manager modules and bridge config |
| `packages/` | Custom flake packages |
| `config/` | Static config files and templates |
| `lib/` | Repo helper functions |
| `bin/` | Helper scripts |

## Outputs

Useful discovery commands:

```sh
nix flake show
nix eval .#nixosConfigurations --apply builtins.attrNames
nix eval .#darwinConfigurations --apply builtins.attrNames
nix eval .#homeConfigurations --apply builtins.attrNames
```

These discovery commands include dormant outputs, which may not evaluate.

## Common commands

From repo root:

```sh
# Evaluate the active hosts
bin/check-fleet

# Build a NixOS system
nix build .#nixosConfigurations.<host>.config.system.build.toplevel

# Switch a NixOS host
sudo nixos-rebuild switch --flake .#<host> --impure

# Switch the local nix-darwin host with the pinned rebuild tool
bin/rswitch switch

# Apply a standalone Home Manager profile
home-manager switch --flake .#<profile>
```

Some hosts use secrets or machine-local state. Pure evaluation/build checks can
fail if a service validates files that only exist after activation.

## Adding or adapting a NixOS host

1. Pick closest existing host under `hosts/nixos/`.
2. Copy it to `hosts/nixos/<new-host>/`.
3. Generate fresh hardware config:

   ```sh
   sudo nixos-generate-config --show-hardware-config \
     > hosts/nixos/<new-host>/hardware-configuration.nix
   ```

4. Review `mounts.nix`, disks, bootloader, networking, secrets, and enabled
   modules.
5. Rebuild:

   ```sh
   sudo nixos-rebuild switch --flake .#<new-host> --impure
   ```

For a fresh install, follow the official NixOS installation guide first, mount
target filesystems under `/mnt`, clone this repo, adapt a host config, then run:

```sh
sudo nixos-install --root /mnt --flake /path/to/dotfiles#<new-host> --impure
```

## Darwin bootstrap

Install Nix, enable flakes, install Homebrew if the host config uses Brew, then
build and switch the darwin configuration:

```sh
curl -L https://nixos.org/nix/install | sh
mkdir -p ~/.config/nix
printf 'experimental-features = nix-command flakes\n' > ~/.config/nix/nix.conf
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
nix build .#darwinConfigurations.ATGRZMBP43.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#ATGRZMBP43
```

See `hosts/darwin/README.md` for bootstrap notes.

## Secrets

Secrets are managed with `sops-nix`. Host age keys live outside the repo.

Generate/install a host key:

```sh
sudo bin/setup-sops-age-key
sudo age-keygen -y /var/lib/sops-nix/$(hostname -s).txt
```

Reference secrets from host configs, for example:

```nix
sops.secrets."my-service/env".path = "/var/secrets/my-service.env";
```

Do not commit plaintext secrets.

## Infrastructure notes

### Attic cache

`purple` acts as local binary cache server. Clients can enable the reusable
module under `modules.nix.atticCache` and point at `purple-ts:5129`.

Manual push example:

```sh
attic push purple-cache /run/current-system
```

### Remote builds

`purple` can act as remote builder. Hosts can opt in with:

```nix
modules.nix.remoteBuilder = {
  enable = true;
  host = "purple";
  user = "builder";
  systems = [ "x86_64-linux" ];
};
```

### Headscale / Tailscale

`jam` runs Headscale. To add a new node:

```sh
sudo headscale preauthkeys create --user <user> --reusable --expiration 24h
sudo tailscale up --login-server https://<jam-domain-or-ip>:443 --authkey <PREAUTH_KEY>
sudo headscale nodes list
```

## Links

- [NixOS download](https://nixos.org/download.html)
- [NixOS manual](https://nixos.org/manual/nixos/stable/)
- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)
- [sops-nix](https://github.com/Mic92/sops-nix)
