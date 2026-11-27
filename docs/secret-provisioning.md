# Host secret provisioning

Each host has one SOPS file, `secrets/<host>.yaml`. Vaultwarden holds the recovery copy of service credentials. Host private age identities stay on their hosts. Do not create a separate encrypted file per credential.

## Dry run on either Mac

From the dotfiles checkout on ATGRZMBP43 or thistle, use the pinned CLI tools:

```sh
nix develop '.#secrets' --command bash
```

On first use only, configure the CLI and log in to Vaultwarden. Do not copy CLI state or session tokens between Macs.

```sh
bw config server 'https://passwort.xn--berwachungsbehr-mtb1g.de'
bw login
bw lock
```

The helper works while the vault is locked. It asks you to unlock, verifies a read of the designated test item without displaying any fields, and locks again. It sends only an age-encrypted dummy string to the host and prompts interactively for remote sudo if needed. It does not write to Vaultwarden, update YAML, or deploy.

```sh
./bin/provision-host-secret --dry-run teal 096870d0-d6f2-4eec-a007-b1851ceb14e6
```

`jam` is also supported. Use a trusted SSH host key and a working `teal` or `jam` alias on each Mac. The target needs `age` on the SSH user's PATH and sudo access to read its existing age identity. The helper does not install packages or export identities. A successful run ends with `Encrypted dummy handoff verified for teal`. If an age identity rotates, update the helper's public recipient to match that host's `.sops.yaml`.

An apply mode is not implemented. The dry run deliberately never uses a real vault value in the handoff.
