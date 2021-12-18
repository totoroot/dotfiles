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

      environment.systemPackages = with pkgs; [
        # mount remote directories
        sshfs
        # mount exfat drives (macOS compatibility)
        exfat
        # utilities for the btrfs filesystem
        btrfs-progs
        # creates and maintains the history of snapshots of btrfs filesystems
        unstable.btrfs-snap
        # visualize the layout of a mounted btrfs
        # btrfs-heatmap
        # mount ntfs drives (Windows compatibility)
        ntfs3g
        # partitioning tool
        parted
        # graphical disk usage utility
        unstable.duf
        # drive health monitoring
        smartmontools
        # tool to get/set ATA/SATA drive parameters under Linux
        hdparm
        # get disk temperature for ATA/SATA drives
        hddtemp
        # menu-driven mounting tool for removeable drives
        bashmount
        # data recovery utilities
        testdisk
        # tools to support Logical Volume Management (LVM)
        lvm2
        # NVM-Express user space tooling for Linux
        nvme-cli
        # LUKS disk encryption
        cryptsetup
      ];

      # add user to group disk for access on disks without sudo
      user.extraGroups = [ "disk" ];

      services.udev = {
      extraRules = ''
        KERNEL=="sd*", ACTION=="add", ATTR{removable}=="1", \
        RUN+="$XDG_BIN_HOME/polybar-scripts/usb-mount.sh --update"
        KERNEL=="sd*", ACTION=="remove", \
        RUN+="$XDG_BIN_HOME/polybar-scripts/usb-mount.sh --update"
        '';
    };
    }
  ]);
}
