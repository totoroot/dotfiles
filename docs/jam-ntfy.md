# Jam ntfy accounts

Jam provisions three regular accounts when `ntfy-sh.service` starts. The existing anonymous topic rules stay unchanged.

| Account | `jam-backups` | `uptime-alerts` |
| --- | --- | --- |
| `mathym-desktop` | Read-only | Read-only |
| `mathym-phone` | Read-only | Read-only |
| `jam-backup-publisher` | Write-only | No access |

## Prepare credentials

Run `ntfy user hash` separately for each account on a trusted machine and enter its password at the prompt. Use different passwords for desktop and phone. The publisher can use a random password because the backup notifier uses a token. Do not create the accounts with `ntfy user add`.

On a machine that can decrypt jam's secrets, open `secrets/jam.yaml` with `sops edit secrets/jam.yaml` and add this top-level entry. Replace each placeholder with the complete bcrypt hash and keep the environment assignment on one line:

```yaml
NTFY_AUTH_ENV: |
  NTFY_AUTH_USERS='mathym-desktop:DESKTOP_BCRYPT_HASH:user,mathym-phone:PHONE_BCRYPT_HASH:user,jam-backup-publisher:PUBLISHER_BCRYPT_HASH:user'
```

Use the single quotes shown and leave the `$` characters in the hashes unchanged. Keep the passwords, hashes, and publisher token out of chat and plaintext Git. sops-nix installs the environment file at `/var/secrets/ntfy-auth.env` as `root:root`, mode `0400`. Do not rebuild until the encrypted key and the NixOS changes are both present.

## Migrate and verify

Before the first rebuild with this configuration, make a protected SQLite backup of `/var/lib/ntfy-sh/user.db` on jam. For example, with the SQLite CLI:

```sh
sqlite=$(command -v sqlite3)
test -n "$sqlite" && sudo "$sqlite" /var/lib/ntfy-sh/user.db \
  ".backup /root/ntfy-user-pre-provision-$(date -u +%Y%m%dT%H%M%SZ).db"
```

If `sqlite3` is not installed, enter a shell with `nix shell nixpkgs#sqlite` first. The database copy contains authentication state. Keep it under `/root` and out of Git.

Keep the existing `jam-backup-publisher` user. ntfy 2.37.2 adopts an existing username in place, updating its password hash and declared ACL without recreating its row or removing a manually issued token. Declare the publisher token in the same SOPS-protected `NTFY_AUTH_ENV` value by adding a second environment line. Do not use `ntfy token add`, which would leave it only in the live database:

```text
NTFY_AUTH_TOKENS='jam-backup-publisher:YOUR_GENERATED_TOKEN:Jam backup alerts'
```

Also add a top-level SOPS string named `RESTIC_PANTRY_NTFY_CURL` containing the curl config for the notifier. Use the same token value, and keep the whole config value in SOPS:

```text
url = "https://ntfy.thym.it/jam-backups"
header = "Authorization: Bearer YOUR_GENERATED_TOKEN"
```

The `RESTIC_PANTRY_NTFY_CURL` secret is installed as root-only `/var/secrets/restic-pantry-ntfy.curl`. After rebuilding, check the accounts and permissions on jam:

```sh
sudo env NTFY_AUTH_FILE=/var/lib/ntfy-sh/user.db \
  NTFY_AUTH_DEFAULT_ACCESS=deny-all ntfy user list
```

Subscribe to `jam-backups` on each client with the respective reader credentials. If the notifier already has the publisher token configured, send a test with `sudo systemctl start restic-pantry-notify.service` and verify delivery. See [backup monitoring](jam-backups.md#monitoring) for the notifier setup. If the HTTPS path redirects to Authelia or rejects the token, diagnose the proxy path rather than making the topic public.

Do not roll back to a configuration without these users and assume the auth database will stay unchanged. ntfy can remove provisioned users (and their tokens) when they no longer appear in configuration. Preserve the SQLite backup for recovery.
