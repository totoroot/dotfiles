# modules/hardware/disks.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.disks;
in {
  options.modules.hardware.disks = {
    enable = mkBoolOpt false;
    btrfs = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.udisks2.enable = true;

      programs.udevil.enable = true;

      services.smartd = {
        enable = true;
        autodetect = true;
        notifications = {
          x11.enable = true;
          test = true;
        };
      };

      environment.systemPackages = with pkgs; [
        # Mount exfat drives (macOS compatibility)
        exfat
        # Mount ntfs drives (Windows compatibility)
        ntfs3g
        # BTRFS
        btrfs-progs
        # XFS
        xfsprogs
        # Non-destructive FAT16/FAT32 resizer
        fatresize
        # Partitioning tool
        parted
        # Graphical disk usage utility
        duf
        # Drive health monitoring
        smartmontools
        # Tool to get/set ATA/SATA drive parameters under Linux
        hdparm
        # Get disk temperature for ATA/SATA drives
        hddtemp
        # Menu-driven mounting tool for removeable drives
        bashmount
        # Data recovery utilities
        testdisk
        # Tools to support Logical Volume Management (LVM)
        lvm2
        # NVM-Express user space tooling for Linux
        nvme-cli
        # LUKS disk encryption
        cryptsetup
        # Removable disk automounter for udisks
        udiskie
        # Sync files and directories to and from major cloud storage
        rclone
        # Command-line WebDAV client
        cadaver
      ];

      # Add user to group disk for access on disks without sudo
      user.extraGroups = [ "disk" ];

      environment = {
        shellAliases = {
          # Not interested in special devices
          duf = "duf -only local,fuse,network";
        };
      };
    }

    (mkIf cfg.btrfs {
      services.btrfs.autoScrub = {
        enable = true;
        fileSystems = [ "/" ];
        interval = "weekly";
      };

      environment.systemPackages = with pkgs; [
        # Utilities for the btrfs filesystem
        btrfs-progs
        # Creates and maintains the history of snapshots of btrfs filesystems
        btrfs-snap
        # Visualize the layout of a mounted btrfs
        btrfs-heatmap
      ];
    })
  ]);
}
