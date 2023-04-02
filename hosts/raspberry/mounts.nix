{ config, pkgs, ... }:
{
  programs.fuse.userAllowOther = true;

  environment.systemPackages = with pkgs; [
    # Mount remote directories over SSH
    sshfs
    # Mount WebDAV shares
    davfs2
  ];
  
  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  # Use 2GB of additional swap memory in order to not run out of memory
  # when installing lots of things while running other things at the same time.
  swapDevices = [ { device = "/swapfile"; size = 2048; } ];
}
