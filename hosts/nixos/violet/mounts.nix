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
      options = [ "noatime" "nofail" "x-systemd.device-timeout=5s" ];
    };
    "/mnt/time-machine-thistle" = {
      device = "/dev/disk/by-label/tmthistle";
      fsType = "xfs";
      options = [ "noatime" "recovery" ];
    };
    "/mnt/time-machine-work" = {
      device = "/dev/disk/by-label/work";
      fsType = "xfs";
      options = [ "noatime" "recovery" ];
    };
    fileSystems."/mnt/photos" = {
      device = "/dev/disk/by-label/photos";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd" ];
    };
    fileSystems."/mnt/photos-backup" = {
      device = "/dev/disk/by-label/photos-backup";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd" ];
    };
    fileSystems."/mnt/media" = {
      device = "/dev/disk/by-label/media";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd" ];
    };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
}
