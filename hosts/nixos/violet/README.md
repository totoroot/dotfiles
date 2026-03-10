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

## RAID Notes
- Capacity: with four 10TB disks, RAID10 and RAID6 both yield 50% usable capacity. There is no space advantage for RAID6 at this disk count.
- Rebuild behavior: RAID10 rebuilds are faster and less stressful because they copy from a mirror partner, while RAID6 rebuilds must reconstruct parity across all disks, which is slower and more I/O intensive.
- Performance: RAID10 generally offers better random I/O and more predictable writes, which fits mixed media + backup usage. RAID6 has slower writes due to parity updates.
- Fault tolerance: RAID10 survives any single disk failure, and two failures only if they are in different mirror pairs. If both disks in the same mirror pair fail, the array fails. RAID6 can survive any two disk failures, but rebuilds are heavier and take longer, increasing exposure time.
- When RAID6 makes sense: typically 6+ disks, where you want to tolerate any two failures and are okay with slower writes and longer rebuilds.
- How to map mirror pairs: check `mdadm --detail /dev/md0` or `/proc/mdstat` and map member order to mirror pairs for the active RAID10 layout.
