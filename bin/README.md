# Helper scripts

Run `bin/<script>` from the repo root, or use `nix develop` to put `bin/` on `PATH`.

| Task | Helpers |
| --- | --- |
| Evaluate or deploy | [`check-fleet`](check-fleet), [`rswitch --help`](rswitch). See [active-host operations](../docs/active-hosts.md). |
| Provision secrets | [`provision-host-secret`](provision-host-secret), [`setup-sops-age-key`](setup-sops-age-key). See the [provisioning runbook](../docs/secret-provisioning.md). |
| Inspect overlays or profiles | [`check-overlays`](check-overlays), [`nix-profile-audit`](nix-profile-audit). See [overlay troubleshooting](../docs/overlays-troubleshoot.md). |
| Inspect certificates and uptime | [`cert example.com`](cert), [`check-cert-renewal`](check-cert-renewal), [`healthchecks-upsert`](healthchecks-upsert). See [certificate renewal](../docs/certificate-renewal.md) and [Healthchecks](../docs/healthchecks.md). |
| Work with binary caches | [`setup-attic-cache`](setup-attic-cache), [`attic-client-token`](attic-client-token). See [infrastructure notes](../docs/infrastructure.md). |
| Everyday utilities | [`get-releases`](get-releases) lists releases from a remote Git repository. [`memstat`](memstat) reports memory usage. |
