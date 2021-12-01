# Overview

## Installation

### Set up root file system

```
# SanDisk Plus
parted /dev/sdb -- mklabel gpt
parted /dev/sdb -- mkpart primary 1GB 175GB
parted /dev/sdb -- mkpart primary 175GB 100%
parted /dev/sdb -- mkpart primary linux-swap -24GB 100%
parted /dev/sdb -- mkpart ESP fat32 1MB 1GB
parted /dev/sdb -- set 4 esp on

mkfs.fat -F 32 -n boot /dev/sdb4
mkfs.ext4 -L nixos /dev/sdb1
mkfs.ext4 -L home /dev/sdb2
mkswap -L swap /dev/sdb3
```

### Mount drives

```zsh
mount /dev/sdb1 /mnt

mkdir -p /mnt/{home,boot}
mount /dev/sdb4 /mnt/boot
mount /dev/sdb2 /mnt/home
swapon /dev/sdb3
```
