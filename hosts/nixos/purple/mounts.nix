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
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "btrfs";
      options = [ "noatime" ];
    };
    "/mnt/backup" = {
      device = "/dev/disk/by-label/backup";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    # "/mnt/violet" = {
    #   device = "mathym@violet:";
    #   fsType = "sshfs";
    #   options = [
    #     # Filesystem options
    #     # For non-root access
    #     "allow_other"
    #     # This is a network fs
    #     "_netdev"
    #     # Mount on demand
    #     "x-systemd.automount"
    #     # Prevent long "start job is running" wait times
    #     "x-systemd.device-timeoup=1ms"
    #     "follow_symlinks"
    #     # SSH options
    #     # Handle connection drops
    #     "reconnect"
    #     # Keep connections alive
    #     "ServerAliveInterval=15"
    #     "ServerAliveCountMax=3"
    #     "IdentityFile=/home/mathym/.ssh/purple"
    #     # Troubleshoot connection
    #     # "sshfs_debug"
    #     # Debugging options
    #     "debug"
    #     "loglevel=debug"
    #   ];
    # };
    # "/mnt/photos" = {
    #   device = "mathym@violet:/mnt/photos";
    #   fsType = "sshfs";
    #   options = [
    #     # Filesystem options
    #     # For non-root access
    #     "allow_other"
    #     # This is a network fs
    #     "_netdev"
    #     # Mount on demand
    #     "x-systemd.automount"
    #     # Prevent long "start job is running" wait times
    #     "x-systemd.device-timeoup=1ms"
    #     "follow_symlinks"
    #     # SSH options
    #     # Handle connection drops
    #     "reconnect"
    #     # Keep connections alive
    #     "ServerAliveInterval=15"
    #     "ServerAliveCountMax=3"
    #     "IdentityFile=/home/mathym/.ssh/purple"
    #     # Troubleshoot connection
    #     # "sshfs_debug"
    #     # Debugging options
    #     "debug"
    #     "loglevel=debug"
    #   ];
    # };
    # "/mnt/music" = {
    # device = "mathym@violet:/mnt/music";
    # fsType = "sshfs";
    # options = [
    # # Filesystem options
    # # For non-root access
    # "allow_other"
    # # This is a network fs
    # "_netdev"
    # # Mount on demand
    # "x-systemd.automount"
    # # Prevent long "start job is running" wait times
    # "x-systemd.device-timeoup=1ms"
    # "follow_symlinks"
    # # SSH options
    # # Handle connection drops
    # "reconnect"
    # # Keep connections alive
    # "ServerAliveInterval=15"
    # "ServerAliveCountMax=3"
    # "IdentityFile=/home/mathym/.ssh/purple"
    # # Troubleshoot connection
    # # "sshfs_debug"
    # # Debugging options
    # "debug"
    # "loglevel=debug"
    # ];
    # };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
}
