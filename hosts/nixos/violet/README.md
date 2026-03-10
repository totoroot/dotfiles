# violet

My most beautiful and beefy server. Still the same motherboard as when we started, but one of the most beautiful outer shells, I've ever seen. violet features professional graphics and good overall specs as well.

## Hardware Details
  - **Motherboard**: Biostar A10N-8800
  - **CPU**: AMD FX-8800P SoC
  - **GPU**: AMD Radeon WX3200
  - **CPU Cooler**: SoC Cooler with Noctua
  - **RAM**: 2 x Kingston HyperX FURY DDR4 16GB
  - **Disks**:
    -
  - **Power Supply**: BeQuiet SFX Power 3 300W
  - **Case**: Jonsbo N1
  - **System Fans**: Noctua Redux

## Storage Notes
  - LUKS array uses a single shared keyfile; mapper names are `luks-disk1..4` for consistency.
  - Keyfile secret name: `QUAD_LUKS_KEY` in `secrets/violet.yaml` (YAML `|-` to avoid trailing newline).
  - Optional TPM2 unlock: see TODO.md for enrollment commands and notes about re-enrolling after motherboard changes.
  - Current approach: sops-nix installs the key at `/run/secrets/quad-luks-key` post-boot. A systemd oneshot unlocks the disks, assembles mdadm, and activates LVM so boot never blocks on missing disks.
  - Initrd no longer embeds the keyfile to avoid fragile build-time secret handling.

## Photos and Media Storage
Photos live on `/dev/sde1` encrypted with LUKS as `photos-crypt`, formatted as btrfs and mounted at `/mnt/photos`. This is the only location where photos are stored; it is encrypted at rest and intended to be accessed directly by Immich. Daily btrfs snapshots from `/mnt/photos` are meant to be sent to `/mnt/photos-backup`, which is an LVM LV on the RAID10 array (`quad/photos-backup`) formatted as btrfs.

Jellyfin media is stored on the RAID10 array in the `quad/media` LV, formatted as btrfs and mounted at `/mnt/media`. This is not backed up, but benefits from RAID10 redundancy for availability. Both `/mnt/photos-backup` and `/mnt/media` are defined declaratively in `hosts/nixos/violet/mounts.nix` and created manually via `lvcreate` + `mkfs.btrfs`.

Additional backup LVs on the RAID10 array are created manually and mounted declaratively: `quad/violet-backup` → `/mnt/backup-violet`, `quad/jam-backup` → `/mnt/backup-jam`, and `quad/grape-backup` → `/mnt/backup-grape`. All are btrfs and intended for system backups from those hosts.

The LUKS unlock for `/dev/sde1` happens post‑boot in the `luks-open-disks` systemd oneshot, alongside the RAID member disks. This avoids blocking boot while still bringing the encrypted photos volume online automatically once secrets are available.

## RAID Notes
- Capacity: with four 10TB disks, RAID10 and RAID6 both yield 50% usable capacity. There is no space advantage for RAID6 at this disk count.
- Rebuild behavior: RAID10 rebuilds are faster and less stressful because they copy from a mirror partner, while RAID6 rebuilds must reconstruct parity across all disks, which is slower and more I/O intensive.
- Performance: RAID10 generally offers better random I/O and more predictable writes, which fits mixed media + backup usage. RAID6 has slower writes due to parity updates.
- Fault tolerance: RAID10 survives any single disk failure, and two failures only if they are in different mirror pairs. If both disks in the same mirror pair fail, the array fails. RAID6 can survive any two disk failures, but rebuilds are heavier and take longer, increasing exposure time.
- When RAID6 makes sense: typically 6+ disks, where you want to tolerate any two failures and are okay with slower writes and longer rebuilds.
- How to map mirror pairs: check `mdadm --detail /dev/md0` or `/proc/mdstat` and map member order to mirror pairs for the active RAID10 layout.
