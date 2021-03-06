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

      # Support for more filesystems, mostly to support external drives
      environment.systemPackages = with pkgs; [
        sshfs           # mount remote directories
        exfat           # mount exfat drives (macOS compatibility)
        ntfs3g          # mount ntfs drives (Windows compatibility)
        parted          # partitioning tool
        unstable.duf    # graphical disk usage utility
        smartmontools   # drive health monitoring
        hdparm          # get disk speeds
        bashmount       # menu-driven mounting tool for removeable drives
        testdisk        # data recovery utilities
      ];

      # add user to group disk for access on disks without sudo
      user.extraGroups = [ "disk" ];
    }
  ]);
}
