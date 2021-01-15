[![NixOS 20.09](https://img.shields.io/badge/NixOS-v20.09-blue.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)

**Hey,** you. You're finally awake. You were trying to configure your OS declaratively, right? Walked right into that NixOS ambush, same as us, and those dotfiles over there.

Note that this repository is a fork of [Henrik Lissner's dotfiles](https://github.com/hlissner/dotfiles).

**Screenshots follow as soon as bspwm config is done.**

------

| | |
|-|-|
| **Shell:** | zsh + zgen |
| **DM:** | lightdm + lightdm-mini-greeter |
| **WM:** | bspwm + polybar |
| **Editor:** | [micro] (and occasionally vim) |
| **Terminal:** | kitty |
| **Launcher:** | rofi |
| **Browser:** | firefox |
| **GTK Theme:** | [Ant Dracula](https://github.com/EliverLara/Ant-Dracula) |

-----

## Quick start

1. Yoink [NixOS 20.09][nixos].
2. Boot into the installer.
3. Do your partitions and mount your root to `/mnt`. I recommend first doing `sudo su` for ease of use. Be careful with those labels though.
4. Clone the repo with `git clone https://github.com/totoroot/dotfiles-nixos /mnt/etc/nixos`.
6. In case git is not installed, run `nix-env -iA nixos.git`.
7. Make sure the config you are about to install has the right hardware-configuration.
8. For a new host enter the cloned repo and duplicate an existing configuration (`cd nixos && cp -r hosts/purple hosts/<new-host>`) and make adjustments with `nano hosts/<new-host>/default.nix`.

   For a different partitioning scheme make sure to change the hardware-configuration with `nano hosts/<new-host>/hardware-configuration.nix`.

   In case you dont know how to set up this config run `nixos-generate-config --dir hosts/<new-host>/ && rm hosts/<new-host>/configuration.nix`
9. Add nixPkgs channel and install flakes `nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && nix-channel --update && nix-env -iA nixpkgs.nixFlakes`.
10. Install NixOS with configuration for host "purple" `nixos-install --root /mnt --flake /mnt/etc/nixos#purple`.
11. Edit either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` and add `experimental-features = nix-command flakes`.

This is needed to expose the Nix 2.0 CLI and flakes support that are hidden behind feature-flags. 

11. Reboot!

## Management

And I say, `bin/hey`. [What's going on?](http://hemansings.com/)

| Command           | Description                                                     |
|-------------------|-----------------------------------------------------------------|
| `hey rebuild`     | Rebuild this flake (shortcut: `hey re`)                         |
| `hey upgrade`     | Update flake lockfile and switch to it (shortcut: `hey up`)     |
| `hey update`      | Update flake lockfile (shortcut: `hey u`)                       |
| `hey rollback`    | Roll back to previous system generation                         |
| `hey gc`          | Runs `nix-collect-garbage -d`. Use sudo to clean system profile |
| `hey push REMOTE` | Deploy these dotfiles to REMOTE (over ssh)                      |
| `hey check`       | Run tests and checks for this flake                             |
| `hey show`        | Show flake outputs of this repo                                 |

## Frequently asked questions

+ **Why NixOS?**

  Because declarative, generational, and immutable configuration is a godsend
  when you have a fleet of computers to manage.
  
+ **How do I change the default username?**

  1. Set `USER` the first time you run `nixos-install`: `USER=myusername
     nixos-install --root /mnt --flake #XYZ`
  2. Or change `"mathym"` in modules/options.nix.

+ **How do I "set up my partitions"?**

  My main host [has a README](hosts/purple/README.org) you can use as a reference.
  I set up an EFI+GPT system and partitions with `parted`.
  
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
[nixos]: https://releases.nixos.org/?prefix=nixos/20.09-small/
[host/purple]: https://github.com/totoroot/dotfiles/tree/master/hosts/purple
