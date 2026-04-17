## TODO

We update this file as we go. Priority order: top to bottom.

### Now

- [ ] Fix Jellyfin deployment (violet backend, jam reverse-proxy, stable media UX)
  - [ ] Verify service health end-to-end (`jellyfin`, `jellyseerr`, nginx upstream from `jam`)
  - [ ] Ensure domain split is final (`medien.<domain>` for Jellyfin, `wunschliste.<domain>` for Jellyseerr)
  - [ ] Add/validate firewall rules for tailnet-only backend access on `violet`
  - [ ] Validate DB migration for Jellyseerr to Postgres and remove any SQLite leftovers
  - [ ] Add explicit operational checks in Gatus for both endpoints (+ auth expectation if protected)

- [ ] Set up Sonarr, Radarr, Prowlarr (declarative media automation stack)
  - [ ] Create service modules (or one combined arr-stack module) with sane defaults
  - [ ] Add Postgres/SQLite decision and data dir strategy per service
  - [ ] Wire reverse proxy subdomains + Authelia protection policy
  - [ ] Define download client integration + media path conventions on `violet`
  - [ ] Add backup scope for arr configs and DBs

- [ ] Set up Plausible (self-hosted) (mostly done, hardening/documentation left)
  - [x] Evaluate current prerequisites on `jam` (Postgres present, clickhouse strategy, SMTP already local)
  - [x] Decide deployment mode (native NixOS module vs pod/container)
  - [x] Configure ingestion domain + dashboard domain + Authelia policy for admin UI
  - [ ] Define retention, backup, and restore procedures
  - [x] Add smoke-test endpoint + Gatus checks

- [ ] Finalize `thym.it` mail migration on `jam`
  - [ ] DMARC rollout for `thym.it` (currently `p=none`)
    - [ ] move to `v=DMARC1; p=quarantine; rua=mailto:admin@thym.it; adkim=s; aspf=s; pct=100` after confirming legit mail still aligns
    - [ ] later move to `v=DMARC1; p=reject; rua=mailto:admin@thym.it; adkim=s; aspf=s; pct=100` after quarantine period stays clean
  - [ ] Remove legacy `überwachungsbehör.de` mail acceptance after grace period
    - [ ] remove legacy aliases from mailserver config
    - [ ] remove legacy DNS records/config no longer needed

- [ ] Forgejo + runner bootstrap issues on `jam` (blocked)
  - [ ] Runner service fails first-boot bootstrap (`.runner` missing in `/var/lib/gitea-runner/codeberg`)
  - [ ] Investigate why `services.gitea-actions-runner` does not create instance state dir declaratively on this channel
  - [ ] Verify token ingestion path for `tokenFile` (observed "token is empty" during auto-register despite non-empty secret)
  - [ ] Decide final auth mode for Forgejo DB (socket/peer vs password) and keep it fully declarative
  - [ ] Re-enable `forgejo` and `forgejo-runner` on `jam` after bootstrap path is stable

- [ ] Establish deployment strategy for static websites (runner-backed, currently blocked on forgejo path)
  - [ ] Set up self-hosted Forgejo runner on `jam` first (dedicated unprivileged runner user)
  - [ ] Define one declarative deploy module for static sites (`sites` attrset: domain, root, keepReleases, healthcheck)
  - [ ] Implement atomic release flow (`incoming` artifact -> `releases/<ts>-<sha>` -> `current` symlink switch)
  - [ ] Restrict runner write scope to deploy staging paths only; no ad-hoc shell deploys
  - [ ] Add per-site retention + rollback (`previous` pointer or quick symlink rollback)
  - [ ] Migrate `blog.thym.at` and `grueneis-psychologie.at` first, then roll out to remaining `/var/www` sites
  - [ ] Add post-deploy checks (curl + gatus) and deployment metadata (`REVISION`, `BUILD_URL`)

- [ ] Finalize backups on `violet`
  - [ ] Create + mount LVs for `violet-backup`, `jam-backup`, `grape-backup`
  - [ ] Add declarative mounts in `hosts/nixos/violet/mounts.nix`
  - [ ] Add backup jobs/services (remote hosts -> `violet`)
  - [ ] Document restore steps in `hosts/nixos/violet/README.md`

- [ ] Add Paperless-ngx module for `violet`
  - [x] NixOS service module
  - [x] Postgres wiring
  - [x] Network exposure limited to local LAN + tailnet
  - [ ] Reverse proxy from `jam`

### Next

- [ ] Plan and execute `violet` system disk migration to btrfs
  - [ ] Define subvolume layout
  - [ ] Snapshot + rollback approach
  - [ ] Migration/restore checklist in `violet-migration.md`

- [ ] Media stack decision for `violet`
  - [ ] Evaluate adding Navidrome beside Jellyfin for music-only workflows

### Cleanup / follow-up

- [ ] Remove legacy basic-auth secret files no longer referenced by nginx
- [ ] Re-enable and validate `needsreboot` activation hook on `violet`
