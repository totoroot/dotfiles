# Theaterschaffen on jam

## Prepared configuration

- Canonical origin: `https://die.theaterschaffen.de`.
- Webroot: `/var/www/die.theaterschaffen.de`.
- Ownership: `deploy-web:deploy-web`, directory mode `0755`, declared in jam's `systemd.tmpfiles.rules`.
- German content remains at `/`, English at `/en/`.
- `theaterschaffen.de` and `*.theaterschaffen.de` permanently redirect to the canonical origin, preserving path and query string. The redirect vhost accepts HTTP and HTTPS and sends both directly to the fixed HTTPS destination.
- The exact canonical nginx host takes precedence over the wildcard, preventing a redirect loop.
- The dedicated `der.theaterschaffen.de` vhost is removed. It is now handled by the wildcard redirect. No filesystem deletion is performed by this change.
- `julia.thym.at` redirects to the canonical origin rather than the apex.
- Missing canonical pages use the Hugo German 404 page. Missing `/en/` pages use the English 404 page.

The old `/var/www/theaterschaffen.de` and `/var/www/julia` contents are not deleted or migrated. The user will handle `/var/www/fabian` separately. Nix rollback cannot restore files deleted manually, so back up anything still needed before removing that directory.

## DNS and certificates

Read-only DNS checks confirmed that the apex, canonical hostname and an arbitrary first-level subdomain resolve to jam's IPv4 address, `45.83.104.124`. Authoritative DNS is Netcup. No DNS records were modified.

A shared ACME certificate covers `theaterschaffen.de` and `*.theaterschaffen.de`. It uses Netcup DNS-01 and the existing credential files declared for jam:

- `/var/secrets/acme/netcup-customer-number`
- `/var/secrets/acme/netcup-api-key`
- `/var/secrets/acme/netcup-api-password`

No credential values were read, copied or added. Before activation, confirm that these credentials can update the theaterschaffen.de zone. DNS-01 certificate issuance will write temporary challenge records when the configuration is activated.

The wildcard certificate covers one subdomain level, including `die`, `der`, `www` and arbitrary single labels. It does not cover names such as `a.b.theaterschaffen.de`. Such names need explicit certificate coverage before HTTPS redirects can work, even if DNS or nginx matches them.

## Rollout order

Do not switch nginx to an empty webroot.

1. Review the complete dotfiles diff. The working tree already contains unrelated jam Jellyfin and monitoring changes. Isolate or separately review them before activating a generation. A whole-host switch can activate those changes too.
2. Resolve publication decisions for legal drafts and provisional programme-PDF reuse in the website repository. Keep website deployment manual until approved.
3. Publish the new website and theme repositories under the established GitLab namespaces, publishing the theme before the website pipeline tries to fetch it. Both private projects have now been created with explicit user approval: `thym.it/website-themes/hugo-theaterschaffen` and `thym.it/websites/die.theaterschaffen.de`. Their local SSH origins are configured. Initial commits and pushes remain pending, and no pipeline has been run.
4. Arrange administrative SSH access to jam. The existing `jam` alias was inspected, but a read-only connection attempt was denied with `Permission denied (publickey)`. No alternate credentials or SSH user were tried.
5. Inspect the proposed webroot on jam. If absent, bootstrap only `/var/www/die.theaterschaffen.de` with owner/group `deploy-web` and mode `0755`, or deploy a tmpfiles-only preparatory change first. Do not recursively change ownership of `/var/www` or modify other sites.
6. Deploy a validated website build into the new webroot before the nginx switch. Its CI target is `/var/www/die.theaterschaffen.de`. Verify that the deployment target is exactly that directory before any rsync deletion step.
7. Activate the reviewed jam configuration through the normal deployment workflow. This will enforce the webroot directory declaration, request the wildcard certificate and change nginx routing. No activation was performed during preparation.
8. Verify the certificate, redirects, German and English pages, localized error pages and PDF range requests. Check other hosted websites for regressions.
9. Only after verification, retire any obsolete content directories the user no longer needs. Keep backups separately if rollback of content is required.

## Validation performed locally

Nix evaluation checked all of the following:

- Canonical webroot and HTTPS configuration.
- Wildcard alias and a permanent fixed-target HTTPS redirect without the extra HTTP-to-same-host hop.
- Absence of a dedicated `der.theaterschaffen.de` vhost.
- Direct legacy `julia.thym.at` redirect target.
- Apex-plus-wildcard certificate, Netcup DNS-01, nginx group and no HTTP webroot challenge.
- Matching `deploy-web` tmpfiles directory rule.
- English 404 route.

The complete `nixosConfigurations.jam.config.system.build.toplevel.drvPath` evaluated successfully. This is evaluation, not a system build, certificate issuance, activation, remote `nginx -t` or runtime verification. The only evaluation warning concerned the existing `system` to `stdenv.hostPlatform.system` rename.

Repeat evaluation without activating:

```sh
nix eval --no-write-lock-file --raw .#nixosConfigurations.jam.config.system.build.toplevel.drvPath
```

## Checks after activation

Do not suppress TLS verification. These alias requests should return a permanent redirect with `Location: https://die.theaterschaffen.de/en/?rollout=1`:

```sh
curl -sS -o /dev/null -D - 'http://theaterschaffen.de/en/?rollout=1'
curl -sS -o /dev/null -D - 'https://theaterschaffen.de/en/?rollout=1'
curl -sS -o /dev/null -D - 'https://www.theaterschaffen.de/en/?rollout=1'
curl -sS -o /dev/null -D - 'https://der.theaterschaffen.de/en/?rollout=1'
curl -sS -o /dev/null -D - 'https://rollout-check.theaterschaffen.de/en/?rollout=1'
```

Canonical pages should return 200 without a hostname redirect:

```sh
curl -sS -o /dev/null -D - https://die.theaterschaffen.de/
curl -sS -o /dev/null -D - https://die.theaterschaffen.de/en/
curl -sS -o /dev/null -D - https://die.theaterschaffen.de/en/work/echtzeitalter/
```

Check both 404 responses and their language. A PDF byte-range request should return 206 and a Content-Range header:

```sh
curl -sS -D - https://die.theaterschaffen.de/not-a-page
curl -sS -D - https://die.theaterschaffen.de/en/not-a-page
curl -sS --range 0-31 -D - -o /dev/null \
  https://die.theaterschaffen.de/dokumente/rabenhof-saison-2018-19/rabenhof-saison-2018-19.pdf
```

Then inspect nginx/ACME service status and certificate renewal logs on jam using the established administrative workflow.
