# Host secret provisioning

Each host has one SOPS file, `secrets/<host>.yaml`. Vaultwarden holds the recovery copy of service credentials. Host private age identities stay on their hosts. Do not create a separate encrypted file per credential.

For a new NixOS host only, [`bin/setup-sops-age-key`](../bin/setup-sops-age-key) can set up the identity on that host. Review any changes it makes to `.sops.yaml` and the host's YAML stub. Encrypt the file with `sops` before staging it, and never commit the private identity or plaintext credentials. For an existing host, use its current identity and encrypted file.

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

## Add a secret to jam or teal

For the mail canary, save the check's Ping URL in a Vaultwarden Login item's password field. The item can be in a collection that the CLI account can read. Use the item's UUID, not the collection UUID. The helper only reads Vaultwarden items and locks the local CLI when finished.

From the dotfiles checkout on either Mac:

```sh
./bin/provision-host-secret --curl-url teal mail-canary-heartbeat VAULT_ITEM_ID
```

The host argument selects the SSH alias, age recipient, and encrypted YAML. `jam` uses this dotfiles checkout. `teal` uses the standard environments checkout, which can be overridden with `TEAL_ENVIRONMENTS_DIR`. The pinned secrets shell starts automatically if local tools are missing.

Use `--apply HOST SOPS_KEY VAULT_ITEM_ID` to add a Login password or Secure Note exactly as stored. Use `--curl-url` instead when the consuming service expects a Healthchecks.io URL formatted as a curl config.

Confirm the target when prompted. If `age`, `sops`, or `jq` is missing from the target's PATH, the helper loads the tools temporarily using that checkout's pinned Nixpkgs revision. The target uses its existing age key through interactive sudo. Only the encrypted payload and a copy of the existing encrypted YAML are uploaded. The helper refuses to overwrite an existing entry and returns only encrypted YAML. It replaces your local file after verification, without committing or deploying. Review `git status` in the selected checkout before committing and deploying separately.
