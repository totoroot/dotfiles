# Jam backup and recovery

## Current status

- Jam runs nightly PostgreSQL logical dumps at 01:00 UTC (02:00 CET, 03:00 CEST). The manual run produced a 21 MiB archive that passed `gzip -t`. A database restore has not been tested.
- The encrypted Restic repository `0403d19480` was initialized from the Mac on `pantry`. SFTP public-key authentication on port 22 was verified from the Mac. No production snapshot has been uploaded, and no Restic timer or external monitoring is configured.

## Backup destination

`pantry` is a Hetzner Storage Box BX11 in Falkenstein, Germany, separate from jam's Netcup VPS. Repository: `sftp:u725720@u725720.your-storagebox.de:jam-restic`. Use SFTP on port 22. The console's port 23 refers to Hetzner's extended SSH service, which this setup does not need.

The box has deletion protection and snapshot directory access enabled. Automatic snapshots run daily at 04:00 UTC, with eight retained to leave room for two manual snapshots. No subaccounts are configured. Storage Box snapshots do not replace Restic retention, and box deletion protection should not be treated as protection against deletion of individual repository files.

| Tier | Capacity | Monthly price before VAT |
| --- | ---: | ---: |
| BX11 | 1 TB | €3.20 |
| BX21 | 5 TB | €10.90 |
| BX31 | 10 TB | €20.80 |
| BX41 | 20 TB | €40.60 |

These are the console prices recorded at setup, not guaranteed future prices. Rescaling keeps the data in place. Downgrades require both usage and snapshot counts to fit the smaller tier.

## Recovery gaps (deferred)

- **The Restic password is currently stored in Vaultwarden on jam.** If jam and Vaultwarden are unavailable and there is no independent copy, the repository cannot be decrypted. Store a recovery copy off-host and verify it from a device that does not rely on jam. Restic cannot reset a lost repository password.
- The dedicated SFTP private key is currently on the Mac only. Verify an independent way to regain Storage Box access, such as adding a fresh recovery key through the Hetzner Console. Keep console access and any required MFA recovery material independent of jam as well.
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

1. Provision jam's dedicated SFTP private key as a root-only runtime credential and pin the verified Storage Box host key on jam. SOPS is unchanged for now. Run the first upload manually with the Restic password entered at the prompt.
2. Back up `/var/backup/postgresql/all.sql.gz` first. Restore the resulting snapshot into a restricted scratch directory from another machine, then import it into a disposable PostgreSQL cluster with compatible versions and extensions. Check that the expected databases and roles exist and sample the recovered data. Never import the full cluster dump into production as a test.
3. Confirm the full backup scope: the PostgreSQL dump, Nextcloud data and configuration, `/var/vmail`, `/var/www`, and a verified Vaultwarden backup artifact. Check that Nextcloud's file and database recovery points are consistent. Exclude caches and the Nix store.
4. Automate nightly backups after a successful fresh dump. Proposed retention: 14 daily, 8 weekly, and 6 monthly snapshots. Let Restic manage retention and pruning. Alert on failed runs with ntfy and add an off-host heartbeat check for stale backups, since jam also hosts ntfy.
5. Measure repository growth and test restores periodically. Add violet as an independent second destination when it returns.

Do not call the setup recoverable until an off-host restore succeeds without relying on secrets available only through jam.
