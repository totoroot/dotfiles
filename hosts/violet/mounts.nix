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
    };
    "/mnt/photos" = {
      device = "/dev/disk/by-label/photos";
      fsType = "ext4";
    };
    "/mnt/music" = {
      device = "/dev/disk/by-label/music";
      fsType = "ext4";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
}
