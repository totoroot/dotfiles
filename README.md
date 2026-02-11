# NixOS/Nix system and user configuration for my private machines

<a href="https://codeberg.org/totoroot/dotfiles">
    <img alt="Get it on Codeberg" src="https://get-it-on.codeberg.org/get-it-on-blue-on-white.png" height="88">
</a>

[![NixOS 24.05](https://img.shields.io/badge/NixOS-24.11-blue.svg?style=flat&logo=NixOS&logoColor=white)](https://nixos.org)

[![Commit activity](https://img.shields.io/github/commit-activity/m/totoroot/dotfiles?style=flat)](https://codeberg.org/totoroot/dotfiles/activity/monthly)
[![Latest commit](https://img.shields.io/github/last-commit/totoroot/dotfiles/main?label=Latest%20Commit&style=flat)](https://codeberg.org/totoroot/dotfiles/commits/branch/main)


**Hey,** you. You're finally awake. You were trying to configure your OS declaratively, right? Walked right into that NixOS ambush, same as us, and those dotfiles over there.

Note that this repository is a fork of [Henrik Lissner's dotfiles](https://github.com/hlissner/dotfiles) which I have modified and updated over the years to better suit my needs.

In case you need help getting started with NixOS and want to use these dotfiles as a starting point, feel free to raise issues asking for help or send me an Email to my Git commit address which you can find on my profile.

## Screenshots 4K Display

![Full Desktop](https://codeberg.org/totoroot/dotfiles/raw/branch/screenshots/screenshot-full.png)
![Floating Desktop](https://codeberg.org/totoroot/dotfiles/raw/branch/screenshots/screenshot-floating.png)

------

| | |
|-|-|
| **Shell:** | zsh + zgenom |
| **DM:** | lightdm + lightdm-mini-greeter |
| **WM:** | bspwm + polybar |
| **Editor:** | [micro] (and occasionally nvim) |
| **Terminal:** | [kitty] |
| **Launcher:** | rofi |
| **Browser:** | firefox |
| **GTK Theme:** | [Ant Dracula](https://github.com/EliverLara/Ant-Dracula) |

-----

If you've never before installed NixOS, make sure to read through the [official installation guide](https://nixos.wiki/wiki/NixOS_Installation_Guide). This quick start guide is based on the [installation instructions in the official NixOS manual](https://nixos.org/manual/nixos/stable/index.html#ch-installation) so you might want to skim over them as well before getting started.

Also, if you run into any issues, especially when trying to follow the installation instructions and you get stuck, please open an issue either [on Codeberg](https://codeberg.org/totoroot/dotfiles/issues/new) or [on GitHub](https://github.com/totoroot/dotfiles/issues/new).

## Quick start

### Using the minimal installer image

1. Yoink the minimal ISO image of [NixOS from the official download page][nixos].

2. Verify integrity of the ISO image and flash to boot medium.

3. Boot into the installer.

4. Create the mount directories with `mkdir -p /mnt/boot`.

5. Do your partitions and mount your root to `/mnt`. I recommend first doing `sudo su` for ease of use. Be careful with those labels though.

6. Check whether everything is mounted correctly by running `lsblk`. Check disk labels by running `blkid`.

4. Install `git` with `nix-env -iA nixos.git`.

5. Make sure you've got a working, stable network connection as it will be needed for installing/rebuilding the system's configuration.

### Using the graphical installer image

1. Install NixOS following the [official instructions for graphical installation](https://nixos.org/manual/nixos/stable/#sec-installation-graphical) according to your needs (encryption, partioning etc.).
  Since most of my hosts use KDE Plasma as a desktop environment at the moment, it makes sense to use the KDE Plasma image, so that the first rebuild will not take as long.
  For most platforms, this should work without any issues with the default configuration. You should not have to configure much before installing NixOS.

2. Reboot your system and boot into your system's first generation.

3. Open a terminal. If you used the KDE Plasma image, launch Konsole.

### Continuing with the install/rebuild

6. Clone the dotfiles to any directory in your home directory. I prefer putting it alongside other dotfiles in `~/.config/`.
  `git clone https://codeberg.org/totoroot/dotfiles ~/.config/dotfiles`

7. Look through available configurations in the `hosts` directory. Every host subdirectory includes a little README, that should help you figure out, which host configuration you could base your configuration on.
  For a desktop PC look at `purple`, for a server look at `violet`, for a notebook look at `grape`.

8. Once you found a configuration you like, copy its directory and think of a good name for your new host. Then run `cp -r ~/.config/dotfiles/hosts/grape ~/.config/dotfiles/hosts/<new-host>`.

9. Overwrite the hardware configuration file in the copied directory with a new one.
  Run `sudo nixos-generate-config --show-hardware-config > ~/.config/dotfiles/hosts/<new-host>/hardware-configuration.nix`

10. In case you want to make adjustments to the configuration, do it now.

11. Check whether the partitioning scheme in  `~/.config/dotfiles/hosts/<new-host>/hardware-configuration.nix` is correct.

12. Add nixpkgs channel and install flakes `nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && nix-channel --update && nix-env -iA nixpkgs.nixFlakes`.

13. In case you have already installed with the graphical installer and rebooted, rebuild your system with the following command.
  `nixos-rebuild boot --flake /mnt/etc/nixos#<new-host> --impure`

13. In case you haven't yet installed, run the installer with the following command:
  `nixos-install --root /mnt --flake /mnt/etc/nixos#<new-host> --impure`

14. Reboot!

## Management

Since Nix tooling can be confusing, I'm occasionally using [hlissner's](https://github.com/hlissner) wrapper `hey`.

For example to rebuild your system using the flake, run `hey re` instead of `nixos-rebuild switch --flake /mnt/etc/nixos#<host> --impure`.

And I say, `bin/hey`. [What's going on?](http://hemansings.com/)

```
Usage: hey [global-options] [command] [sub-options]

Available Commands:
  check                  Run 'nix flake check' on your dotfiles
  gc                     Garbage collect & optimize nix store
  generations            Explore, manage, diff across generations
  help [SUBCOMMAND]      Show usage information for this script or a subcommand
  rebuild                Rebuild the current system's flake
  repl                   Open a nix-repl with nixpkgs and dotfiles preloaded
  rollback               Roll back to last generation
  search                 Search nixpkgs for a package
  show                   [ARGS...]
  ssh HOST [COMMAND]     Run a bin/hey command on a remote NixOS system
  swap PATH [PATH...]    Recursively swap nix-store symlinks with copies (or back).
  test                   Quickly rebuild, for quick iteration
  theme THEME_NAME       Quickly swap to another theme module
  update [INPUT...]      Update specific flakes or all of them
  upgrade                Update all flakes and rebuild system

Options:
    -d, --dryrun                     Don't change anything; preform dry run
    -D, --debug                      Show trace on nix errors
    -f, --flake URI                  Change target flake to URI
    -h, --help                       Display this help, or help for a specific command
    -i, -A, -q, -e, -p               Forward to nix-env
```

## Some information to get you started configuring the install to your needs
Mimeapps can be set in `modules/xdg.nix`.

## Frequently asked questions

+ **Why NixOS?**

  Because declarative, generational, and immutable configuration is a godsend
  when you have a fleet of computers to manage.

+ **How do I change the default username?**

  1. Set the `USER` environment variable the first time you run `nixos-install`:
  `USER=myusername nixos-install --root /mnt --flake /path/to/dotfiles#XYZ`
  2. Or change `"mathym"` in modules/options.nix.

+ **How do I "set up my partitions"?**

  My main host [has a README](hosts/purple/README.org) you can use as a reference.
  I set up an EFI+GPT system and partitions with `parted`.

  **Why did you write bin/hey?**

    I envy Guix's CLI and want similar for NixOS, but its toolchain is spread
    across many commands, none of which are as intuitive: `nix`,
    `nix-collect-garbage`, `nixos-rebuild`, `nix-env`, `nix-shell`.

    I don't claim `hey` is the answer, but everybody likes their own brew.

+ **How 2 flakes?**

  Would it be the NixOS experience if I gave you all the answers in one,
  convenient place?

  No, but here are some resources that helped me:

  + [A three-part tweag article that everyone's read.](https://www.tweag.io/blog/2020-05-25-flakes/)
  + [An overengineered config to scare off beginners.](https://github.com/nrdxp/nixflk)
  + [A minimalistic config for scared beginners.](https://github.com/colemickens/nixos-flake-example)
  + [A nixos wiki page that spells out the format of flake.nix.](https://nixos.wiki/wiki/Flakes)
  + [Official documentation that nobody reads.](https://nixos.org/learn.html)
  + [Some great videos on general nixOS tooling and hackery.](https://www.youtube.com/channel/UC-cY3DcYladGdFQWIKL90SQ)
  + A couple flake configs that I
    [may](https://github.com/LEXUGE/nixos)
    [have](https://github.com/bqv/nixrc)
    [shamelessly](https://git.sr.ht/~dunklecat/nixos-config/tree)
    [rummaged](https://github.com/utdemir/dotfiles)
    [through](https://github.com/purcell/dotfiles).
  + [Some notes about using Nix](https://github.com/justinwoo/nix-shorts)
  + [What helped me figure out generators (for npm, yarn, python and haskell)](https://myme.no/posts/2020-01-26-nixos-for-development.html)
  + [What y'all will need when Nix drives you to drink.](https://www.youtube.com/watch?v=Eni9PPPPBpg)

## Infrastructure

### Attic cache (purple)

Attic is used as the local binary cache. Purple acts as the server and clients point to it over Tailscale.

On purple:

```
sudo bin/setup-attic-cache purple-cache 5129
sudo nixos-rebuild switch --flake .#purple --impure
sudo atticd-atticadm make-token \
  --sub admin \
  --validity "10 years" \
  --pull "*" \
  --push "*" \
  --delete "*" \
  --create-cache "*"
attic login purple-cache http://purple-ts:5129 <JWT>
attic cache create purple-cache
attic cache info purple-cache
```

Copy the "Public Key" into `modules.nix.atticCache.publicKey` on clients.

To manually push the current system to the cache:

```
attic push purple-cache /run/current-system
```

This is not necessary if the watcher is enabled on purple.

### Remote builders (purple)

Purple is the remote builder. Hosts can enable it with:

```
modules.nix.remoteBuilder = {
  enable = true;
  host = "purple";
  user = "builder";
  systems = [ "x86_64-linux" ]; # or "aarch64-linux" if purple supports it
};
```

### sops-nix (age)

Secrets are managed with sops-nix. Generate a host key:

```
sudo bin/setup-sops-age-key
sudo age-keygen -y /var/lib/sops-nix/$(hostname -s).txt
```

Create the encrypted secrets file:

```
sops --encrypt --age "age1...HOST_PUBLIC_KEY..." -i secrets/<host>.yaml
```

Then reference secrets in host configs:

```
sops.secrets."my-service/env".path = "/var/secrets/my-service.env";
```

### Headscale (jam) / Tailscale tailnet

To add a new node to the tailnet via headscale on `jam`:

1. Create a pre-auth key on jam:

```
sudo headscale preauthkeys create --user <user> --reusable --expiration 24h
```

2. On the new host, join using the key:

```
sudo tailscale up --login-server https://<jam-domain-or-ip>:443 --authkey <PREAUTH_KEY>
```

3. Verify the node shows up:

```
sudo headscale nodes list
```


[micro]: https://micro-editor.github.io
[kitty]: https://sw.kovidgoyal.net/kitty/
[nixos]: https://nixos.org/download.html
[host/purple]: https://github.com/totoroot/dotfiles/tree/master/hosts/purple
