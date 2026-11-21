# Changedetection on jam

Changedetection runs on jam and listens on `127.0.0.1:5002`. Nginx serves [website.überwachungsbehör.de](https://website.xn--berwachungsbehr-mtb1g.de/) behind Authelia and proxies to the local instance. No SSH tunnel or firewall opening is needed. The `change-alerts` topic remains private, with separate reader and publisher accounts.

The cutover does not copy violet's old datastore. Jam keeps its own watches and history under `/var/lib/changedetection-io`. If you need old watches or history, back up both datastores before attempting a migration.

## Before deploying

On jam, use `ntfy user hash` to hash a new random password for `jam-change-publisher`, and use `ntfy token generate` to generate its publisher token. Keep both values private. In `sops edit secrets/jam.yaml`, append these entries to the existing lines in the `NTFY_AUTH_ENV` block. Do not overwrite the existing accounts or backup token.

- On `NTFY_AUTH_USERS`, append `,jam-change-publisher:YOUR_BCRYPT_HASH:user` inside the single quotes.
- On `NTFY_AUTH_TOKENS`, append `,jam-change-publisher:YOUR_TOKEN:Changedetection` inside the single quotes.

Deploy only after both the encrypted update and the ACL changes are included. ntfy rejects a declarative ACL that references a missing provisioned user.

## Add and test a watch

After deploying, verify that a signed-out browser is redirected to Authelia and that signing in opens Changedetection.

1. Open [website.überwachungsbehör.de](https://website.xn--berwachungsbehr-mtb1g.de/), add the site URL, and start with the default HTTP fetcher and no content filters. This compares extracted page text, not every underlying HTML or visual change. If the site renders relevant content with JavaScript, a browser fetcher may be needed.
2. In the watch's notification settings, add `ntfy://127.0.0.1:6780/change-alerts?token=YOUR_TOKEN`. The URL is evaluated on jam, not on the Mac. Enter it directly in the dashboard. Do not paste the real token into chat or Git.
3. Subscribe to `change-alerts` on `https://ntfy.thym.it` using the existing reader account. Send a test notification from Changedetection and confirm it reaches the phone. Set the watch's check interval and verify the first fetch becomes its baseline.

The notification URL is stored in Changedetection's local state. Do not share that state or notification debug logs. This directory is not currently part of the Restic backup scope.
