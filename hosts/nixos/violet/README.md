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
  - LUKS array uses a single shared keyfile with initrd unlock; mapper names are `luks-disk1..4` for consistency.
  - Keyfile secret name: `QUAD_LUKS_KEY` in `secrets/violet.yaml` (YAML `|-` to avoid trailing newline).
  - Optional TPM2 unlock: see TODO.md for enrollment commands and notes about re-enrolling after motherboard changes.
  - Current approach: unencrypted keyfile at `/etc/crypto_keyfile.bin` (fallback) + TPM2 unlock slots enrolled on each disk.
  - Nix config assumes keyfile exists at `/etc/crypto_keyfile.bin` and embeds it into initrd.
