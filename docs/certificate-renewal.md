# Certificate Renewal Troubleshooting

Quick reference for ACME/Let's Encrypt cert renewal issues on hosts using NixOS `security.acme`.

## Fast detection

List failed ACME renewal units:

```bash
systemctl --failed --plain --no-legend | awk '{print $1}' | grep '^acme-order-renew-'
```

Print affected certificate names only:

```bash
systemctl --failed --plain --no-legend | awk '{print $1}' | grep '^acme-order-renew-' | sed 's/^acme-order-renew-//; s/\.service$//'
```

Find units failing with the known ARI/account-mismatch error:

```bash
systemctl list-unit-files 'acme-order-renew-*.service' --no-legend | awk '{print $1}' | while read -r u; do journalctl -u "$u" -n 50 --no-pager | grep -q "requester account did not request the certificate being replaced by this order" && echo "$u"; done
```

## Symptom

Renewal unit fails with logs like:

```text
acme: error: 403 :: urn:ietf:params:acme:error:unauthorized :: Could not validate ARI 'replaces' field :: requester account did not request the certificate being replaced by this order
```

This means lego is trying to renew an existing cert lineage with a different ACME account than the one that originally requested the cert.

## Why this happens

A common cause is ACME account migration, for example:

- old certs issued under `admin@thym.at`
- current renewal units use `admin@thym.it`

When lego performs ARI-based renewal (`renew --dynamic`), Let's Encrypt rejects the renewal because the current account does not own the old lineage.

## Verify a specific cert

Check local cert expiry:

```bash
sudo openssl x509 -in /var/lib/acme/<name>/fullchain.pem -noout -dates -issuer -subject
```

Check live cert served by nginx:

```bash
echo | openssl s_client -connect <hostname>:443 -servername <hostname> 2>/dev/null | openssl x509 -noout -dates -issuer -subject
```

Check renewal unit logs:

```bash
systemctl status acme-order-renew-<name>.service --no-pager
journalctl -u acme-order-renew-<name>.service -n 200 --no-pager
```

## Safe repair procedure

Back up the cert and lineage state first:

```bash
sudo mkdir -p /root/acme-backups/<name>
sudo cp -a /var/lib/acme/<name> /root/acme-backups/<name>/
sudo cp -a /var/lib/acme/.lego/<name> /root/acme-backups/<name>/
```

Force fresh issuance for that cert only:

```bash
sudo rm -rf /var/lib/acme/.lego/<name>
sudo rm -f /var/lib/acme/<name>/*.pem
sudo systemctl start acme-order-renew-<name>.service
journalctl -u acme-order-renew-<name>.service -n 200 --no-pager
```

Verify the new cert:

```bash
sudo openssl x509 -in /var/lib/acme/<name>/fullchain.pem -noout -dates -issuer -subject
echo | openssl s_client -connect <hostname>:443 -servername <hostname> 2>/dev/null | openssl x509 -noout -dates -issuer -subject
```

## Important safety notes

- Only remove lineage state for the affected cert.
- Do **not** wipe `/var/lib/acme/.lego/accounts` globally.
- Do **not** remove unrelated certs.
- Repair certs one-by-one unless you are very confident in the scope.

## Useful inventory commands

List cert directories:

```bash
ls -1 /var/lib/acme
```

Show expiry for all certs on disk:

```bash
for d in /var/lib/acme/*; do if [ -f "$d/fullchain.pem" ]; then echo -n "$(basename "$d") "; openssl x509 -in "$d/fullchain.pem" -noout -enddate; fi; done
```

Show only expired certs:

```bash
for d in /var/lib/acme/*; do if [ -f "$d/fullchain.pem" ]; then n=$(basename "$d"); e=$(openssl x509 -in "$d/fullchain.pem" -noout -enddate | cut -d= -f2); t=$(date -d "$e" +%s); now=$(date +%s); [ "$t" -le "$now" ] && echo "$n EXPIRED $e"; fi; done
```

## Best quick detector in practice

For this repo, the fastest high-signal command was:

```bash
systemctl --failed --plain --no-legend | awk '{print $1}' | grep '^acme-order-renew-'
```

And to print only certificate names:

```bash
systemctl --failed --plain --no-legend | awk '{print $1}' | grep '^acme-order-renew-' | sed 's/^acme-order-renew-//; s/\.service$//'
```

This catches certs whose renewal units are currently failed, which turned out to be the most practical way to identify affected domains during incident response.

## Runbook: repair all currently failed renewal units one by one

Print names:

```bash
systemctl --failed --plain --no-legend | awk '{print $1}' | grep '^acme-order-renew-' | sed 's/^acme-order-renew-//; s/\.service$//'
```

Repair one cert:

```bash
name='example.org'
sudo mkdir -p /root/acme-backups/"$name"
sudo cp -a /var/lib/acme/"$name" /root/acme-backups/"$name"/
sudo cp -a /var/lib/acme/.lego/"$name" /root/acme-backups/"$name"/
sudo rm -rf /var/lib/acme/.lego/"$name"
sudo rm -f /var/lib/acme/"$name"/*.pem
sudo systemctl start "acme-order-renew-$name.service"
journalctl -u "acme-order-renew-$name.service" -n 100 --no-pager
```
