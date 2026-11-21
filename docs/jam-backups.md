# Jam backup and recovery

## Current status

- Jam's PostgreSQL dump has been verified locally with `gzip -t`. A database import has not been tested.
- The encrypted Restic repository `0403d19480` was initialized on `pantry`. Jam uploaded the PostgreSQL dump as snapshot `4d326540`. The Mac restored it with Restic verification, and the restored archive passed `gzip -t`. Import into PostgreSQL is deferred.
- The systemd timer ran at 02:15 Europe/Vienna and saved the first expanded snapshot, `d73e55da`. The job requires a successful fresh dump and reads its repository password from sops-nix. Pruning is disabled. The monitoring hooks below require deployment and local credentials before they can send alerts.

## Backup scope

| Path | What it covers |
| --- | --- |
| `/var/backup/postgresql/all.sql.gz` | Fresh logical dump of the PostgreSQL cluster, including the Nextcloud and Vaultwarden databases |
| `/var/vmail` | The configured mail store on jam. `/var/mail` is not where the virtual mailboxes live. |
| `/var/lib/nextcloud` | Nextcloud data and local configuration |
| `/var/www` | Deployed site files and assets |
| `/var/lib/vaultwarden` | Vaultwarden file state, such as attachments and configuration, without re-uploading its rotating local archives |

The first expanded upload succeeded, but its individual paths have not been restored and tested. The job reads live application files without pausing services, so the file tree and database dump are not an atomic recovery point. Test an application restore before relying on that combination. The Nix store, live PostgreSQL directory, and `/var/secrets` are not backup inputs. Keep independently recoverable configuration and credentials for services that require them.

## Backup destination

Jam backs up over SFTP to [`pantry`](pantry.md), a Hetzner Storage Box separate from jam's Netcup VPS. The Storage Box setup page records connection details, console settings, snapshot limits, and pricing.

## Recovery gaps (deferred)

- **The Restic password is currently stored in Vaultwarden on jam.** An independent, verified recovery copy is deferred. Storing the password in SOPS for runtime use does not close this gap while SOPS depends on jam's age identity. Restic cannot reset a lost repository password.
- The dedicated SFTP private key is on the Mac and installed as a root-only file on jam at `/var/lib/restic-jam/key`, alongside the pinned `known_hosts` file. Verify an independent way to regain Storage Box access, such as adding a fresh recovery key through the Hetzner Console. Keep console access and any required MFA recovery material independent of jam as well.
- Jam's SOPS age identity is at `/var/lib/sops-nix/jam.txt`. No off-host recovery identity or copy has been confirmed. SOPS recovery changes are deferred. Do not put plaintext credentials in Git, the Nix store, or this runbook.

## Verify backups

After deploying the timer, check its schedule and review both services' logs after the first scheduled run:

```sh
systemctl list-timers --all restic-backups-pantry.timer
sudo journalctl -u postgresqlBackup.service -u restic-backups-pantry.service -n 40 --no-pager
```

Look for a successful dump followed by a new `snapshot … saved` line. To verify the local dump separately, run:

```sh
sudo systemctl start postgresqlBackup.service
sudo gzip -t /var/backup/postgresql/all.sql.gz
sudo ls -lh /var/backup/postgresql/all.sql.gz
```

`pg_dumpall` includes all databases in the local cluster and cluster-wide roles. The job keeps the previous dump locally as `all.prev.sql.gz`. Back up only the completed `all.sql.gz`, not the live PostgreSQL data directory or any `.in-progress` file. `gzip -t` verifies the archive stream, not that PostgreSQL can import it.

## Provision the Restic password

Open `secrets/jam.yaml` with `sops edit secrets/jam.yaml` on a trusted machine that can decrypt the file. Add a top-level string named `RESTIC_PANTRY_PASSWORD` using the existing repository password. Do not add a placeholder or create a new repository. Only the encrypted file belongs in Git.

Include the encrypted entry alongside the NixOS wiring before rebuilding jam. The SOPS manifest validates the key during the build. On activation, sops-nix installs it as root-owned `0400` at `/var/secrets/restic-pantry-password`. The service uses that path, not an environment variable containing the password. No SOPS recipients or age keys are changed.

## Monitoring

The PostgreSQL dump and Restic upload both trigger `restic-pantry-notify.service` on failure. Restic triggers `restic-pantry-heartbeat.service` only on success. Notification failures are logged separately and do not change the backup result. Missing credential files skip their respective hooks, so deploying the units alone does not enable alert delivery.

On jam, provision the following curl config files as `root:root`, mode `0600`. Use only a trusted editor, put the real values in the files rather than shell arguments, and keep them out of Git:

- `/var/secrets/restic-pantry-ntfy.curl`: an authenticated, private ntfy topic. Give the token's account publish access only where needed.

  ```text
  url = "https://ntfy.thym.it/jam-backups"
  header = "Authorization: Bearer YOUR_NTFY_TOKEN"
  ```

- `/var/secrets/restic-pantry-heartbeat.curl`: the private success-ping URL for an off-host check, for example [Healthchecks.io](https://healthchecks.io/). Expect one success per day with a two-hour grace period. Route missed-ping alerts independently of jam and its ntfy instance.

  ```text
  url = "https://hc-ping.com/YOUR_CHECK_ID"
  ```

After deploying and provisioning, test both hooks without failing a real backup:

```sh
sudo systemctl start restic-pantry-notify.service   # Sends a real alert
sudo systemctl start restic-pantry-heartbeat.service # Records a test success ping
sudo journalctl -u restic-pantry-notify.service -u restic-pantry-heartbeat.service -n 30 --no-pager
```

Confirm the alert arrives and the monitor records the ping. Then verify a scheduled backup updates the heartbeat automatically. Verify missed-ping delivery separately with a disposable check rather than disrupting the production backup.

## Next steps

1. Provision and verify both monitoring channels.
2. When ready to test database recovery, import the independently restored dump into a disposable PostgreSQL cluster with compatible versions and extensions. Check that the expected databases and roles exist and sample the recovered data. Never import the full cluster dump into production as a test.
3. Verify a snapshot contains the expanded paths and test restoring representative mail, web, Nextcloud, and Vaultwarden files into a scratch location. Assess whether Nextcloud needs coordinated database and file snapshots for reliable recovery.
4. Proposed retention: 14 daily, 8 weekly, and 6 monthly snapshots. Preview the policy before enabling Restic pruning.
5. Measure repository growth and test restores periodically. Add violet as an independent second destination when it returns.

Do not call the setup recoverable until an off-host restore succeeds without relying on secrets available only through jam.
