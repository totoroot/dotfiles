## TODO

We update this file as we go. Priority order: top to bottom.

### Now

- [ ] Declarative uptime monitoring overhaul (`gatus` + existing Uptime Kuma)
  - [ ] Define all endpoint checks in dotfiles (single source of truth)
  - [ ] Add alerts/notifications wiring (ntfy/email)
  - [ ] Decide long-term role of Uptime Kuma (UI-only vs phased migration)

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
  - [ ] Evaluate Jellyfin vs Navidrome/Koel/Funkwhale
  - [ ] Implement chosen module cleanly

### Cleanup / follow-up

- [ ] Re-enable and validate `needsreboot` activation hook on `violet`
