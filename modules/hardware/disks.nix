# modules/hardware/disks.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.disks;
in {
  options.modules.hardware.disks = {
    enable = mkBoolOpt false;
    zfs.enable = mkBoolOpt false;
    ssd.enable = mkBoolOpt false;
    # TODO automount.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
        # Utilities for the btrfs filesystem
        btrfs-progs
        # Creates and maintains the history of snapshots of btrfs filesystems
        unstable.btrfs-snap
        # Visualize the layout of a mounted btrfs
        # btrfs-heatmap
        # Mount ntfs drives (Windows compatibility)
        ntfs3g
        # Non-destructive FAT16/FAT32 resizer
        fatresize
        # Partitioning tool
        parted
        # Graphical disk usage utility
        unstable.duf
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
          duf = "duf -only local";
        };
    }
  ]);
}
