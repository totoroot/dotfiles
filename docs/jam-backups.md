# Jam backup and recovery

## Current status

- Jam runs nightly PostgreSQL logical dumps at 01:00 UTC (02:00 CET, 03:00 CEST). The manual run produced a 21 MiB archive that passed `gzip -t`. A database restore has not been tested.
- The encrypted Restic repository `0403d19480` was initialized on `pantry`. Jam uploaded the PostgreSQL dump as snapshot `4d326540`. The Mac restored it with Restic verification, and the restored archive passed `gzip -t`. Import into PostgreSQL is deferred.
- The NixOS configuration defines `restic-backups-pantry.service` as a manual PostgreSQL-only job. It requires a successful fresh dump, uses a runtime password file at `/var/lib/restic-jam/password`, and does not prune or run on a timer. The unit has not yet been deployed or run on jam. No external monitoring is configured.

## Backup destination

Jam backs up over SFTP to [`pantry`](pantry.md), a Hetzner Storage Box separate from jam's Netcup VPS. The Storage Box setup page records connection details, console settings, snapshot limits, and pricing.

## Recovery gaps (deferred)

- **The Restic password is currently stored in Vaultwarden on jam.** If jam and Vaultwarden are unavailable and there is no independent copy, the repository cannot be decrypted. Store a recovery copy off-host and verify it from a device that does not rely on jam. Restic cannot reset a lost repository password.
- The dedicated SFTP private key is on the Mac and installed as a root-only file on jam at `/var/lib/restic-jam/key`, alongside the pinned `known_hosts` file. Verify an independent way to regain Storage Box access, such as adding a fresh recovery key through the Hetzner Console. Keep console access and any required MFA recovery material independent of jam as well.
- Jam's SOPS age identity is at `/var/lib/sops-nix/jam.txt`. No off-host recovery identity or copy has been confirmed. SOPS recovery changes are deferred. Do not put plaintext credentials in Git, the Nix store, or this runbook.

## Verify the local PostgreSQL dump

On jam:

```sh
systemctl list-timers --all postgresqlBackup.timer
sudo systemctl start postgresqlBackup.service
sudo gzip -t /var/backup/postgresql/all.sql.gz
sudo ls -lh /var/backup/postgresql/all.sql.gz
```

`pg_dumpall` includes all databases in the local cluster and cluster-wide roles. The job keeps the previous dump locally as `all.prev.sql.gz`. Back up only the completed `all.sql.gz`, not the live PostgreSQL data directory or any `.in-progress` file. `gzip -t` verifies the archive stream, not that PostgreSQL can import it.

## Next steps

1. Agree how to provision the Restic password for the systemd job before using it. Leave SOPS unchanged for now. Until then, manual Restic runs can still prompt for the password.
2. When ready to test database recovery, import the independently restored dump into a disposable PostgreSQL cluster with compatible versions and extensions. Check that the expected databases and roles exist and sample the recovered data. Never import the full cluster dump into production as a test.
3. Confirm the full backup scope: the PostgreSQL dump, Nextcloud data and configuration, `/var/vmail`, `/var/www`, and a verified Vaultwarden backup artifact. Check that Nextcloud's file and database recovery points are consistent. Exclude caches and the Nix store.
4. Automate nightly backups after a successful fresh dump. Proposed retention: 14 daily, 8 weekly, and 6 monthly snapshots. Let Restic manage retention and pruning. Alert on failed runs with ntfy and add an off-host heartbeat check for stale backups, since jam also hosts ntfy.
5. Measure repository growth and test restores periodically. Add violet as an independent second destination when it returns.

Do not call the setup recoverable until an off-host restore succeeds without relying on secrets available only through jam.
