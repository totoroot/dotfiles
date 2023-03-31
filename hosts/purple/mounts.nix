{ config, pkgs, ... }:
{
  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [
    # Mount remote directories over SSH
    sshfs
    # Mount WebDAV shares
    davfs2
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  fileSystems."/mnt/violet" = {
    device = "mathym@violet:";
    fsType = "sshfs";
    options = [
      # Filesystem options
      "allow_other"          # for non-root access
      "_netdev"              # this is a network fs
      # "x-systemd.automount"  # mount on demand
      "follow_symlinks"
      # SSH options
      # Handle connection drops
      "reconnect"
      # Keep connections alive
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "IdentityFile=/home/mathym/.ssh/purple"
      # Troubleshoot connection
      # "sshfs_debug"
      # Debugging options
      "debug"
      "loglevel=debug"
    ];
  };
}
