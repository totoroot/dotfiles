# macOS bootstrap

For routine configuration deployments and package upgrades, see [active-host operations](../../docs/active-hosts.md#macos-configuration-and-package-upgrades). Bootstrap uses the checked-in `flake.lock`. It does not require a channel or flake update.

1. Install [Nix](https://nixos.org/download/) in multi-user mode. Enable `nix-command` and `flakes` in your Nix configuration without overwriting existing settings.
2. Check the [host registry](../registry.nix) and choose the config for this machine. The supported hosts are `ATGRZMBP43` and `thistle`. Verify the machine name, primary user, and home directory before proceeding.
3. Review the evaluated Homebrew package lists and activation policy before the first switch. Both configurations use `nix-homebrew` to manage Homebrew and its taps, with migration enabled for existing installs.

From the checkout, for example on `thistle`:

```sh
nix eval .#darwinConfigurations.thistle.config.homebrew.brews
nix eval .#darwinConfigurations.thistle.config.homebrew.casks
nix eval --raw .#darwinConfigurations.thistle.config.homebrew.onActivation.cleanup
nix build --no-update-lock-file .#darwinConfigurations.thistle.system
```

Once the build and activation review pass, follow the [macOS switch runbook](../../docs/active-hosts.md#macos-configuration-and-package-upgrades) to use the pinned rebuild tool.
