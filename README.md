<div align="center">
   
[![Made with Doom Emacs](https://img.shields.io/badge/Made_with-Doom_Emacs-blueviolet.svg?style=flat-square&logo=GNU%20Emacs&logoColor=white)](https://github.com/hlissner/doom-emacs)
[![NixOS 20.09](https://img.shields.io/badge/NixOS-v20.09-blue.svg?style=flat-square&logo=NixOS&logoColor=white)](https://nixos.org)

</div>

**Hey,** you. You're finally awake. You were trying to configure your OS declaratively, right? Walked right into that NixOS ambush, same as us, and those dotfiles over there.

<img src="/../screenshots/alucard/fakebusy.png" width="100%" />

<p align="center">
<span><img src="/../screenshots/alucard/desktop.png" height="178" /></span>
<span><img src="/../screenshots/alucard/rofi.png" height="178" /></span>
<span><img src="/../screenshots/alucard/tiling.png" height="178" /></span>
</p>

------

| | |
|-|-|
| **Shell:** | zsh + zgen |
| **DM:** | lightdm + lightdm-mini-greeter |
| **WM:** | bspwm + polybar |
| **Editor:** | [Doom Emacs][doom-emacs] (and occasionally [vim]) |
| **Terminal:** | st |
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
#11. Edit either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` and add `experimental-features = nix-command flakes`.

This is needed to expose the Nix 2.0 CLI and flakes support that are hidden behind feature-flags. 

11. Reboot!

## Management

And I say, `bin/hey`. [What's going on?](http://hemansings.com/)

| Command           | Description                                                     |
|-------------------|-----------------------------------------------------------------|
| `hey rebuild`     | Rebuild this flake (shortcut: `hey re`)                         |
| `hey upgrade`     | Update flake lockfile and switch to it (shortcut: `hey up`)     |
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
  2. Or change `"hlissner"` in modules/options.nix.

+ **How do I "set up my partitions"?**

  My main host [has a README](hosts/purple/README.org) you can use as a reference.
  I set up an EFI+GPT system and partitions with `parted`.
  
+ **How 2 flakes?**

  It wouldn't be the NixOS experience if I gave you all the answers in one,
  convenient place.


[doom-emacs]: https://github.com/hlissner/doom-emacs
[vim]: https://github.com/hlissner/.vim
[nixos]: https://releases.nixos.org/?prefix=nixos/20.09-small/
[host/kuro]: https://github.com/hlissner/dotfiles/tree/master/hosts/kuro
