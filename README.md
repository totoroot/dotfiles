<a href="https://codeberg.org/totoroot/dotfiles">
    <img alt="Get it on Codeberg" src="https://get-it-on.codeberg.org/get-it-on-blue-on-white.png" height="88">
</a>

[![NixOS 21.11](https://img.shields.io/badge/NixOS-v21.11-blue.svg?style=flat&logo=NixOS&logoColor=white)](https://nixos.org)

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
| **Shell:** | zsh + zgen |
| **DM:** | lightdm + lightdm-mini-greeter |
| **WM:** | bspwm + polybar |
| **Editor:** | [micro] (and occasionally nvim) |
| **Terminal:** | [kitty] |
| **Launcher:** | rofi |
| **Browser:** | firefox |
| **GTK Theme:** | [Ant Dracula](https://github.com/EliverLara/Ant-Dracula) |

-----

If you've never before installed NixOS, make sure to read through the [official installation guide](https://nixos.wiki/wiki/NixOS_Installation_Guide). This quick start guide is based on the [installation instructions in the official NixOS manual](https://nixos.org/manual/nixos/stable/index.html#ch-installation) so you might want to skim over them as well before getting started.


## Quick start

1. Yoink the minimal ISO image of [NixOS from the official download page][nixos].

2. Verify integrity of the ISO image and flash to boot medium.

2. Boot into the installer.

3. Do your partitions and mount your root to `/mnt`. I recommend first doing `sudo su` for ease of use. Be careful with those labels though.

5. Run `nixos-generate-config --root /mnt` to produce the default `configuration.nix` and `hardware-configuration.nix`.

4. Make sure you've got a working network connection and clone the repo with `git clone https://codeberg.org/totoroot/dotfiles /mnt/etc/nixos`.

6. In case this fails, `git` might not be installed. Run `nix-env -iA nixos.git` to install and repeat step 4.

7. For a new host enter the cloned repo and duplicate an existing configuration (`cd nixos && cp -r hosts/purple hosts/<new-host>`) and make adjustments with `nano hosts/<new-host>/default.nix`.

8. Get rid of the default configuration with `rm /mnt/configuration.nix` and override the hardware configuration in the cloned repo for your host with `cp /mnt/hardware-configuration.nix /mnt/etc/nixos/hosts/<new-host>/`.

    For a different partitioning scheme make sure to change the hardware-configuration with `nano hosts/<new-host>/hardware-configuration.nix`.

9. Add nixPkgs channel and install flakes `nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && nix-channel --update && nix-env -iA nixpkgs.nixFlakes`.

10. Install NixOS with configuration for host "purple" `nixos-install --root /mnt --flake /mnt/etc/nixos#purple`.

11. Reboot!

## Management

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


[micro]: https://micro-editor.github.io
[kitty]: https://sw.kovidgoyal.net/kitty/
[nixos]: https://nixos.org/download.html
[host/purple]: https://github.com/totoroot/dotfiles/tree/master/hosts/purple
