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
