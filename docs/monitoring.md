# Monitoring on jam and teal

This is the repository baseline, not a live audit. The jam and teal flakes were evaluated locally. Running services, successful scrapes, UI-created rules, and notification delivery were not verified in this review.

## What we have

| Component | What it does today |
| --- | --- |
| [Gatus](../modules/services/gatus.nix) | Runs 30 one-minute checks from jam for public sites, internal service health, and local mail listeners. The [status page](https://status.xn--berwachungsbehr-mtb1g.de) is behind Authelia. No Gatus notification provider is declared. |
| [Prometheus and Blackbox](../modules/services/prometheus/default.nix) | Prometheus on jam scrapes metrics from jam and, over Tailscale, from purple, violet, and grape. The 19 HTTPS Blackbox targets are probed from jam every two minutes and feed certificate-expiry rules. Gatus, Blackbox, and certificate targets share [one manifest](../hosts/nixos/jam/monitoring-targets.nix). These are not independent vantage points. |
| [Grafana](../modules/services/grafana/default.nix) | Provisioned Prometheus and Loki datasources and dashboards, including Blackbox, certificate expiry, and Postfix. No notification policies or contact points are declared here. The [proxied UI](https://grafana.xn--berwachungsbehr-mtb1g.de) is behind Authelia. |
| [Alloy](../modules/services/alloy.nix) → [Loki](../modules/services/loki.nix) | Collects jam’s systemd journal and adds Postfix/Dovecot mail labels. Loki stores logs locally on jam. No explicit retention policy is declared. The old-sample ingestion limit is not a retention policy. |
| [ntfy](jam-ntfy.md) | Notification transport hosted on jam, not a monitor. A failed backup can publish to `jam-backups`. [Changedetection](jam-changedetection.md) can publish to `change-alerts` when a watch is configured. This path cannot be relied on when jam itself is down. |
| [Healthchecks.io](healthchecks.md) | Independent dead-man’s switch for the [nightly Restic backup](jam-backups.md#monitoring): expects a success heartbeat and is documented to notify via Signal when it is late. This is not yet a general jam or mail uptime check. |
| [GoAccess](../hosts/nixos/jam/default.nix) | nginx access-log analytics, with a Gatus TCP check. Uptime Kuma is disabled on jam. |

The evaluated Prometheus jobs cover node, systemd, StatsD, SMART, Blackbox (probe and exporter), nginx and nginx logs, Fail2ban, ntfy, AdGuard, FRITZ!Box, Speedtest, PostgreSQL, GitLab Runner, Endlessh, Nextcloud, and Home Assistant. A declared job or dashboard is not proof of a healthy scrape. For example, jam is in the Speedtest scrape list but its local exporter is disabled, and `scrapeHosts` entries for Tailscale and Immich do not create jobs. Review actual targets before writing `up` alerts.

## Teal: external uptime and TLS

Teal is a separate netcup VPS (1 vCPU, 1 GiB RAM) managed through Colmena in `thym.it/platform/environments`. Its runbook is `docs/status-service.md` in that repository. `platform/nixos-modules` provides the shared host baseline, and `services/windshift-admin` is unrelated administrative tooling.

- Teal's Gatus is loopback-only. It checks 13 websites, Roundcube, and mail on 25/587 (SMTP STARTTLS) and 465/993 (implicit TLS). The evaluated configuration has 18 availability checks and 36 certificate checks (7 days and 48 hours), every five minutes. Availability checks alert after two failures and notify on recovery after one success.
- Teal's Gatus publishes to a separate, authenticated ntfy instance on teal (`uptime-alerts`), without needing jam, Authelia, or jam's ntfy. The live API returned 54 checks, with the latest results for webmail and all four mail ports successful. The operator ran the synthetic failure/recovery smoke test and confirmed both notifications arrived on Android.
- Teal already provides the external vantage point for jam. Teal cannot report its own total outage through its local ntfy. The Healthchecks.io `teal-monitoring` check is configured with Signal, a five-minute schedule and ten minutes of grace. The matching systemd watchdog is active. The Healthchecks.io API confirmed the first heartbeat at 11:25:01 UTC on 2026-11-27. The operator confirmed the missed-heartbeat Signal alert and restarted the timer. The Healthchecks.io API confirmed recovery at 11:40:15 UTC.

## Mail: current coverage and gaps

[`mail.thym.it`](../modules/services/mailserver.nix) uses Postfix, Dovecot and Rspamd on jam, with Roundcube for webmail.

- Gatus checks `127.0.0.1:25` (SMTP), `:587` (submission), and `:993` (IMAPS) for TCP connectivity only. These checks do not verify public reachability, protocol negotiation, certificates served by the mail daemons, authentication, or delivery. Port 465 is allowed by the evaluated firewall but is not in the check manifest. Confirm which client listeners are in use before extending coverage.
- Gatus and Blackbox check the Roundcube HTTPS endpoint. A working web page and valid nginx HTTPS certificate do not establish that mail works or that SMTP/IMAP serve a current certificate.
- Grafana’s [Postfix Delivery Status dashboard](../modules/services/grafana/dashboards/postfix.json) parses Loki journal entries for delivery attempts, DSNs, deferrals, bounces, and recipient domains. These are historical attempts, not current queue depth or oldest queued message age. A `sent` log on an outbound SMTP hop also does not prove inbox placement.
- Teal covers public transport and certificate checks, but does not authenticate or verify delivery. An inbound canary is prepared for manual testing, not deployed or scheduled. Neither host declares a mail queue scrape. Jam's Prometheus evaluates HTTPS certificate rules, but the evaluated `alertmanagers` list is empty and Alertmanager is disabled. Those rules alone do not notify anyone.

## Recommended rollout

1. **Keep teal responsible for public availability and certificate alerts.** The Android notification path and independent Healthchecks.io → Signal watchdog have been verified. Keep jam's probes for diagnostics and test IPv6 separately if advertised.
2. **Route internal alerts from jam.** Use Alertmanager for grouping, deduplication, and silences, with a compatible ntfy relay. Reserve this route for internal symptoms such as stuck mail, missing exporters and disk pressure. Avoid paging twice for HTTPS or mail certificates already covered by teal.
3. **Verify delivery with a manual inbound canary.** Before deploying the mailbox on jam, the owner adds `MAIL_CANARY_PASSWORD_HASH` to `secrets/jam.yaml`. It must match `mail-canary-imap-password` in teal's `secrets/teal.yaml`. Deploy jam first, then run teal's manual canary to send one tagged message directly to jam's public SMTP listener and verify receipt over authenticated IMAP. If it succeeds under normal filtering, consider running it hourly with a separate missed-success alert. Test outbound delivery separately if an external mailbox becomes available.
4. **Add actionable queue and host telemetry.** Export Postfix queue counts and oldest queued-message age via an exporter or a node textfile collector using `postqueue -j`. Track collection freshness so missing data is not mistaken for an empty queue. Alert on sustained queue age/backlog, failed scrapes or missing expected series, failed mail units, and low free space or inodes on mail storage. Correlate with Loki deferral and bounce trends rather than alerting on every bounce. Verify mail entries and labels appear before relying on log-derived alerts.
5. **Check DNS, capacity, and backend access.** Track MX and address records, PTR/forward DNS, and expected SPF, DKIM and DMARC for the served domains. Validate DKIM and DMARC on received test messages where possible. Set a Loki retention budget and monitor disk usage. Review direct Grafana exposure: the evaluated config binds port 3000 to all interfaces, allows it in the host firewall, and enables anonymous Editor. Confirm upstream reachability controls and restrict backend access to the intended proxy path. Review renderer port 3030 at the same time.

**Next mail milestone:** deploy the dedicated mailbox and verify one manual inbound delivery from teal. Keep Prometheus, Grafana and Loki on jam rather than duplicating them on the 1 GiB VPS.

## Runtime verification checklist

- In Prometheus **Targets**, confirm expected exporters are up. Compare `up` for the Blackbox scrape with `probe_success` for the actual target. Check `probe_ssl_earliest_cert_expiry` and rule state separately.
- In Gatus, confirm the latest local mail and Roundcube results. In Grafana Explore, check recent entries with `{stream="mail", host="jam"}` and compare the Postfix dashboard with the underlying journal. Inspect queue state on jam with `postqueue -p` (read-only, but output contains addresses).
- From the independent runner, confirm it can reach public MX and mail ports without using jam’s resolver or network. Simulate a failure in the check itself rather than stopping production mail. Confirm both failure and recovery notifications on the receiving device.
