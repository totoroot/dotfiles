# Nextcloud: stale `apps_paths` in persisted config

## Symptom

`nextcloud-occ` and `nextcloud-setup.service` fail with errors like:

```text
App directory "/nix/store/...-nextcloud-33.0.6-with-apps/store-apps" not found!
```

This can happen after a Nextcloud/NixOS module change where the generated app layout changes, but persisted state still contains old paths.

## Cause

Nextcloud state in `/var/lib/nextcloud/config/config.php` is persisted.
The NixOS module also provides generated config via `override.config.php`.
If `config.php` contains an old `apps_paths` block, stale store paths can survive even when the generated override is correct.
Once the old store path is garbage-collected, Nextcloud breaks.

## Diagnose on the host

```bash
sudo sed -n '1,220p' /var/lib/nextcloud/config/config.php
sudo ls -l /var/lib/nextcloud/config
sudo sed -n '1,220p' /var/lib/nextcloud/config/override.config.php
sudo -u nextcloud nextcloud-occ status
```

If `config.php` contains old `apps_paths` entries that disagree with `override.config.php`, the persisted file is the problem.

## Fix on the host

Back up the persisted config, then remove only the stale `apps_paths` block from `/var/lib/nextcloud/config/config.php`:

```bash
sudo cp /var/lib/nextcloud/config/config.php /var/lib/nextcloud/config/config.php.bak
sudo python3 - <<'PY'
from pathlib import Path
p = Path('/var/lib/nextcloud/config/config.php')
s = p.read_text()
start = s.index("  'apps_paths' =>")
end = s.index("  'appstoreenabled' =>")
p.write_text(s[:start] + s[end:])
PY
sudo chown nextcloud:nextcloud /var/lib/nextcloud/config/config.php
sudo chmod 640 /var/lib/nextcloud/config/config.php
```

Then verify:

```bash
sudo -u nextcloud nextcloud-occ status
sudo -u nextcloud nextcloud-occ app:list
```

## Notes

- Do **not** try to write into `/nix/store`.
- No declarative repo change is required for this exact issue once the stale persisted key is removed.
- This is a state migration problem, not a package build problem.
