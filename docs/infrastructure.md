# Infrastructure notes

### Attic cache

`purple` is dormant. Its retained configuration acts as a local binary cache
server when online. Clients can enable the reusable
module under `modules.nix.atticCache` and point at `purple-ts:5129`.

Manual push example:

```sh
attic push purple-cache /run/current-system
```

### Remote builds

If `purple` is brought back online, it can act as a remote builder. Hosts can opt in with:

```nix
modules.nix.remoteBuilder = {
  enable = true;
  host = "purple";
  user = "builder";
  systems = [ "x86_64-linux" ];
};
```

### Headscale / Tailscale

`jam` runs Headscale. To add a new node:

```sh
sudo headscale preauthkeys create --user <user> --reusable --expiration 24h
sudo tailscale up --login-server https://<jam-domain-or-ip>:443 --authkey <PREAUTH_KEY>
sudo headscale nodes list
```
