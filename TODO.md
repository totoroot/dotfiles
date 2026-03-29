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

- [ ] Set up Plausible (self-hosted)
  - [ ] Evaluate current prerequisites on `jam` (Postgres present, clickhouse strategy, SMTP already local)
  - [ ] Decide deployment mode (native NixOS module vs pod/container)
  - [ ] Configure ingestion domain + dashboard domain + Authelia policy for admin UI
  - [ ] Define retention, backup, and restore procedures
  - [ ] Add smoke-test endpoint + Gatus checks

- [ ] Establish deployment strategy for static websites (Forgejo/Codeberg-first on `jam`)
  - [ ] Set up self-hosted Forgejo runner on `jam` first (dedicated unprivileged runner user)
  - [ ] Define one declarative deploy module for static sites (`sites` attrset: domain, root, keepReleases, healthcheck)
  - [ ] Implement atomic release flow (`incoming` artifact -> `releases/<ts>-<sha>` -> `current` symlink switch)
  - [ ] Restrict runner write scope to deploy staging paths only; no ad-hoc shell deploys
  - [ ] Add per-site retention + rollback (`previous` pointer or quick symlink rollback)
  - [ ] Migrate `blog.thym.at` and `grueneis-psychologie.at` first, then roll out to remaining `/var/www` sites
  - [ ] Add post-deploy checks (curl + gatus) and deployment metadata (`REVISION`, `BUILD_URL`)

- [ ] Declaratively set Prometheus datasource in Grafana behind SSO
  - [ ] Provision datasource via Grafana provisioning files (in repo)
  - [ ] Keep datasource URL internal while Grafana UI stays Authelia-protected
  - [ ] Add dashboards/provisioning strategy to avoid UI drift
  - [ ] Verify auth boundaries (Grafana users/roles vs Authelia gate)

- [ ] Finalize backups on `violet`
  - [ ] Create + mount LVs for `violet-backup`, `jam-backup`, `grape-backup`
  - [ ] Add declarative mounts in `hosts/nixos/violet/mounts.nix`
  - [ ] Add backup jobs/services (remote hosts -> `violet`)
  - [ ] Document restore steps in `hosts/nixos/violet/README.md`

- [ ] Add Paperless-ngx module for `violet`
  - [ ] NixOS service module
  - [ ] Postgres wiring
  - [ ] Network exposure limited to local LAN + tailnet
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
