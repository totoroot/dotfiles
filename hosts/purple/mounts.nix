{...}
{
    fileSystems."/mnt/violet" = {
    device = "mathym@violet:";
    fsType = "sshfs";
    options =
      [ # Filesystem options
        "allow_other"          # for non-root access
        "_netdev"              # this is a network fs
        # "x-systemd.automount"  # mount on demand

        # SSH options
        "reconnect"              # handle connection drops
        "ServerAliveInterval=15" # keep connections alive
        "IdentityFile=/home/mathym/.ssh/purple"
      ];
  };

  fileSystems."/mnt/lilac" = {
    device = "mathym@lilac:";
    fsType = "sshfs";
    options =
      [ # Filesystem options
        "allow_other"          # for non-root access
        "_netdev"              # this is a network fs
        # "x-systemd.automount"  # mount on demand

        # SSH options
        "reconnect"              # handle connection drops
        "ServerAliveInterval=15" # keep connections alive
        "IdentityFile=/home/mathym/.ssh/purple"
      ];
  };
}
