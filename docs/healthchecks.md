# Healthchecks.io checks

The dotfiles development shell includes `bin/healthchecks-upsert`, which creates or updates a Healthchecks.io check through the v3 API. It matches existing checks by slug, so rerunning the command updates that check instead of creating a duplicate. It does not delete checks or configure alert integrations unless `CHANNELS` is supplied.

## API key

Create a Healthchecks.io **read-write API key** for check management. Store it only in the ignored, local `.envrc.local` file at the repository root:

```sh
export HC_API_KEY='YOUR_READ_WRITE_API_KEY'
```

The root `.envrc` loads this file when present. Run `direnv allow` if direnv requests approval, or enter the repository's `nix develop` shell after loading the local environment. Never commit `.envrc.local` or put the API key in the flake, shell history, command arguments, or chat.

## Create or update a check

```sh
bin/healthchecks-upsert \
  'jam backup' \
  jam-backup \
  '15 2 * * *' \
  Europe/Vienna \
  20700
```

Arguments are name, slug, cron schedule, IANA timezone, grace period in seconds, and optionally channels. The example expects the backup at 02:15 Vienna time and alerts after a 5-hour-45-minute grace period, at about 08:00. Use the precise desired schedule and grace for each job.

Optional channels can be integration names, integration UUIDs, or `*` to assign all existing integrations. Confirm the resulting integrations in the dashboard. The API response includes `ping_url`, which is a **bearer secret**. Store it directly in the appropriate local or SOPS-managed credential file. Never commit it or paste it into logs or chat.

The helper sends `HC_API_KEY` to `https://healthchecks.io/api/v3/checks/` in an HTTP header, not on the command line. It uses the API's `unique: ["slug"]` upsert behavior. Review the existing check and slug before running because a match updates that check's settings.

References: [Healthchecks.io API](https://healthchecks.io/docs/api/) and [API v3 create check](https://healthchecks.io/docs/api/#create-check).
