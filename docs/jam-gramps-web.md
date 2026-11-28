# Gramps Web on jam

[Gramps Web](https://www.grampsweb.org/install_setup/deployment/) runs as a web container and a Celery worker, with Valkey on a dedicated Podman bridge. Image digests and configuration live in [`modules/services/gramps-web.nix`](../modules/services/gramps-web.nix). The app only publishes `127.0.0.1:5085`. There is no public DNS, nginx vhost, or firewall exception.

## First run and private access

After an approved activation, use your existing SSH alias for `jam`:

```sh
ssh -N -o ExitOnForwardFailure=yes -L 127.0.0.1:5085:127.0.0.1:5085 jam
```

Open <http://localhost:5085>, create the owner account, and optionally import a Gramps XML file or connect Gramps Web Sync through the same tunnel. Store the owner password in your password manager. The app generates its own signing secret in the persistent secret directory. No SOPS entry is needed for this setup. Do not publish the first-run wizard.

## Verify operation

On `jam`, after activation:

```sh
systemctl is-active gramps-web-network.service podman-gramps-web.service podman-gramps-web-worker.service podman-gramps-web-valkey.service
curl -fsS -o /dev/null http://127.0.0.1:5085/
journalctl -u podman-gramps-web.service -u podman-gramps-web-worker.service -b
```

Verify the owner can sign in and that a real background job, such as an export, completes before relying on the service. The loopback HTTP check alone does not verify Celery or access to a tree.

## Data and backups

`/var/lib/gramps-web` holds trees, users, media, the signing secret, and derived index and cache data. `/run/gramps-web/tmp` is shared scratch space, not durable storage. The Valkey broker is disposable, so drain background jobs before stopping or upgrading it.

The state directory is **not** in the current `pantry` backup set. Before importing irreplaceable data, arrange an encrypted backup. For a consistent filesystem copy, stop the web and worker containers, back up `/var/lib/gramps-web` including metadata and permissions, then restart the containers. Keep the backup private and test recovery in a separate location.

## Migrate the existing tree to PostgreSQL

The [Jam configuration](../hosts/nixos/jam/gramps-web.nix) separates database provisioning from cutover. With `postgresql.enable = false`, Gramps Web continues using the existing SQLite state. Do not deploy a dirty checkout containing unrelated monitoring changes for this migration.

1. Keep both exports. In an agreed maintenance window, stop `podman-gramps-web-worker.service` and `podman-gramps-web.service` on Jam. Take a root-only backup of all of `/var/lib/gramps-web`, including the users database, signing secret, and any media. Verify the archive can be listed and restored into a separate directory. Restart the old services after the backup. Keep an encrypted copy off Jam. Freeze edits after the final export so the import is not missing later changes.
2. Deploy the database preparation with PostgreSQL mode still off. Verify that `gramps` and `grampswebuser` exist and are owned by their corresponding roles. As the PostgreSQL administrator, set `password_encryption = 'scram-sha-256'` in your interactive session and use `\password gramps` and `\password grampswebuser`. Use separate randomly generated hex passwords. Gramps builds a connection URL internally, so hex also avoids URI-escaping issues. Test both roles over `127.0.0.1` with `psql -W` before switching.
3. On Jam, add the following multiline value under `GRAMPS_WEB_POSTGRESQL_ENV` to the existing `secrets/jam.yaml` using `sops edit`. Store the recovery copy in Vaultwarden. These are placeholders, not deployable credentials:

   ```dotenv
   GRAMPSWEB_POSTGRES_PASSWORD=GRAMPS_ROLE_PASSWORD
   GRAMPSWEB_USER_DB_URI=postgresql+psycopg2://grampswebuser:USER_ROLE_PASSWORD@127.0.0.1:5432/grampswebuser
   ```

4. After reviewing the activation diff, enable PostgreSQL mode in the Jam configuration. The app still listens on `127.0.0.1:5085`, but uses fresh local state at `/var/lib/gramps-web-postgresql`. Its previous data stays at `/var/lib/gramps-web`. Follow the upstream [multi-tree PostgreSQL setup](https://www.grampsweb.org/install_setup/postgres/#creating-a-tree-and-importing-data) to create a new tree and owner, then import the `.gramps` export over the tunnel. Recreate the owner account on the new instance. If there is media, copy it into the new tree's media directory without removing the source.
5. Verify the owner can sign in, compare record counts and sample records with the old tree, and test an edit and background export. Verify both databases appear in the nightly dump and the new tree metadata, media, and signing secret appear in the Restic snapshot. Do not remove the SQLite state or the exports. If validation fails, disable PostgreSQL mode and reactivate the SQLite configuration. Export any writes made on the new tree first, since they will not carry back to SQLite.
