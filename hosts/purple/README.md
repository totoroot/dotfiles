# Overview

## Specs

|THING|TYPE|
|---|---|
|CPU|AMD FX-6300 6-Core 3,5GHz (overclocked)|
|MOBO|ASUS AM3+ M5A97 R2.0|
|COOL|Noctua AM3 Cooler + Noctua NF-P14r redux|
|FANS|2 x Noctua NF-P14r redux +  Noctua NF-S12B redux|
|GPU|Palit GeForce GTX 970 JetStream 4GB|
|RAM|4 x 8GB DDR3 1333MHz Mushkin Essentials|
|PCI|PCI-Express card Icybox M.2 NVMe|
|SSD|500GB Samsung 970 EVO NVMe M.2 SSD|
|SSD|1TB SanDisk Plus SSD|
|SSD|180GB Corsair Force GS SSD|
|HDD|2TB Seagate BarraCuda Compute HDD|
|KBD|DREVO Calibur 60%|
|MOUSE|Anker Wireless Vertical Mouse 2,4GHz|

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