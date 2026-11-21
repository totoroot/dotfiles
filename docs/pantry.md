# pantry: Hetzner Storage Box

`pantry` is a managed backup destination, not a host managed by Nix. See the [infrastructure inventory](inventory.md) for related resources and the [Jam backup and recovery runbook](jam-backups.md) for the Restic workflow and recovery status.

## Resource details

| Field | Value |
| --- | --- |
| Plan | BX11, 1 TB |
| Storage Box hostname | `u725720.your-storagebox.de` |
| Storage Box username | `u725720` |
| Location | Falkenstein, Germany (`eu-central`) |
| Labels | `purpose=backups`, `host=jam` |
| Restic repository | `sftp:u725720@u725720.your-storagebox.de:jam-restic` |
| Restic repository ID | `0403d19480` |

## Console setup

- **Access:** Enable External Reachability for clients outside Hetzner, including jam. Use the dedicated jam backup public key. Keep password and private key material out of Git. Use SFTP on **port 22**. The console shows **port 23** for Hetzner's extended SSH service, which Restic over SFTP does not need. SMB and WebDAV are not required.
- **Snapshots:** Snapshot directory access is enabled. Automatic snapshots run daily at **04:00 UTC** with retention set to **eight**, leaving room for two manual snapshots. The BX11 console lists limits of 10 snapshots, 10 automatic snapshots, and 100 subaccounts. No subaccounts are configured.
- **Protection:** Deletion protection is enabled for the box. Do not treat it as protection against deletion of individual repository files. Storage Box snapshots are separate from Restic snapshots and do not replace Restic retention or restore tests.
- **Client trust:** Jam pins the Storage Box host key at `/var/lib/restic-jam/known_hosts` and uses a dedicated root-only SSH identity at `/var/lib/restic-jam/key`. Verify any unexpected host-key change through a trusted source before updating the pin.

## Capacity and pricing

| Tier | Capacity | Monthly price before VAT |
| --- | ---: | ---: |
| BX11 | 1 TB | €3.20 |
| BX21 | 5 TB | €10.90 |
| BX31 | 10 TB | €20.80 |
| BX41 | 20 TB | €40.60 |

Prices were recorded at setup. Check the console before ordering or resizing. Rescaling keeps data in place. To downgrade, both storage usage and snapshot counts must fit the smaller plan.

References: [Hetzner Storage Box plans](https://www.hetzner.com/storage/storage-box/) and [Hetzner SFTP docs](https://docs.hetzner.com/storage/storage-box/access/access-sftp-scp/).
