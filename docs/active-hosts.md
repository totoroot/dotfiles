# Active-host operations

`jam`, `ATGRZMBP43`, and `thistle` are the supported targets. See the [infrastructure inventory](inventory.md) for host roles and managed resources. Review dormant hosts' hardware and upstream migrations before bringing them back.

## Before deployment

- Run `bin/check-fleet` for shared module or lockfile changes. It attempts each active evaluation from the [host registry](../hosts/registry.nix) and exits nonzero if any fails. It does not build, activate, or update `flake.lock`. Git-backed flake evaluation only sees tracked files, so stage new Nix files or use an isolated path checkout before evaluating.
- For a security update on jam, keep unrelated input and Homebrew updates out of the change. Review the target diff and any stateful migrations before switching.
- Run `bash tests/rswitch.sh` after changing `bin/rswitch`. The tests mock build, profile registration, and activation commands. They do not invoke real `sudo`.

## Jam: switch, boot, and service checks

Use `bin/rswitch switch` from the target checkout. `switch` registers a generation and activates it. `boot` registers a generation for the next boot but does not switch the running services. `test` activates a configuration temporarily without registering it as the next boot default.

After a successful switch, verify the persistent profile, running closure, and bootloader entry separately:

```sh
readlink -f /nix/var/nix/profiles/system
readlink -f /run/current-system
sudo bootctl --no-pager list
```

The two paths and the default entry's `init=` closure should agree. Stop if registration or activation fails, or if the boot entry disagrees. Keep a known-good generation. After reboot, compare `readlink -f /run/booted-system` with the intended closure.

Check service health separately from generation registration:

```sh
systemctl --failed
systemctl is-active nginx.service
curl -fsS https://cloud.thym.at/status.php
```

Also check the specific services changed in the deployment, including their public endpoints where applicable. For an nginx package update, verify the running master executable rather than the binary on `PATH`:

```sh
pid=$(systemctl show nginx.service -p MainPID --value)
if [ "$pid" -gt 0 ]; then sudo "/proc/$pid/exe" -v; fi
```

## Jam: monitoring

See [Monitoring on jam and teal](monitoring.md) for the stack inventory, mail coverage, alerting gaps, and runtime checks.

## Jam: backups and recovery

See [Jam backup and recovery](jam-backups.md) for the PostgreSQL dump, Restic setup, and restore checklist.

## Jam: Gramps Web

See [Gramps Web on jam](jam-gramps-web.md) for private access, first-run setup, and data protection.

## macOS: configuration and package upgrades

`bin/rswitch switch` uses the target's locked nix-darwin rebuild tool. Activation installs missing declared Homebrew packages without a bundle auto-update, upgrade, or cleanup. Review `brew outdated` separately and upgrade named packages explicitly when ready. Do not use zap as part of activation or routine maintenance.

Before a switch that changes Homebrew, compare the installed packages with the target's evaluated `config.homebrew.brews`, `config.homebrew.casks`, and `config.homebrew.onActivation.cleanup`. Stop if declarations are unexpectedly empty or activation would remove software or data.

Home Manager links some config files to the live checkout. Rolling back a generation does not roll those files back independently and does not restore browser profiles or other mutable application data. Back up mutable data before changing application delivery or migrating profiles.
