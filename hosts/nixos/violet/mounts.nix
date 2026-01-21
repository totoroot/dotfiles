{ pkgs, ... }:
{
  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [
    # Mount remote directories over SSH
    sshfs
    # Mount WebDAV shares
    davfs2
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/mnt/clone" = {
      device = "/dev/disk/by-label/clone";
      fsType = "ext4";
      options = [ "noatime" "recovery" ];
    };
    "/mnt/backup-grape" = {
      device = "/dev/disk/by-label/bugrape";
      fsType = "btrfs";
      options = [ "noatime" "recovery" ];
    };
    "/mnt/time-machine-vika" = {
      device = "/dev/disk/by-label/tmvika";
      fsType = "xfs";
      options = [ "noatime" "recovery" ];
    };
    "/mnt/time-machine-mara" = {
      device = "/dev/disk/by-label/tmmara";
      fsType = "xfs";
      options = [ "noatime" "recovery" ];
    };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
}
