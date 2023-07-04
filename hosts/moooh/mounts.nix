{ config, pkgs, ... }:
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
      device = "/dev/disk/by-uuid/d6dc0534-2a5c-4b5c-8091-cdca463c8439";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-uuid/2572-BEF2";
      fsType = "vfat";
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/a60888cd-ccee-4438-a7ac-bad7cb84a120"; } ];
}
