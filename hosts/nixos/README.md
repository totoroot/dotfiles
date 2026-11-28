# NixOS setup

See the [infrastructure inventory](../../docs/inventory.md) for existing machines and the [active-host runbook](../../docs/active-hosts.md) for deployments to `jam`.

For a new machine:

1. Copy the closest configuration to `hosts/nixos/<new-host>/` and add it to [the host registry](../registry.nix). Leave it outside the active fleet gate until it is supported.
2. Generate a fresh `hardware-configuration.nix` on the target with `nixos-generate-config --show-hardware-config`. Review mounts, disks, bootloader, networking, secrets, and enabled services before building.
3. Ensure Git is tracking new flake files, then build with `nix build .#nixosConfigurations.<new-host>.config.system.build.toplevel`.
4. For an existing installation, review the changes and follow the [deployment checks](../../docs/active-hosts.md#before-deployment). For a fresh installation, follow the [NixOS manual](https://nixos.org/manual/nixos/stable/), mount the target filesystems under `/mnt`, and run:

   ```sh
   sudo nixos-install --root /mnt --flake /path/to/dotfiles#<new-host> --impure
   ```
