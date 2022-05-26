{ pkgs, ... }:
{
  # This only exposes the service to purple
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source purple --dport 8384 -j nixos-fw-accept
    iptables -A nixos-fw -p udp --source purple --dport 8384 -j nixos-fw-accept
  '';

  # # This would expose port 8384 to everyone
  # networking.firewall.allowedTCPPorts = [ 8384 ];
  # networking.firewall.allowedUDPPorts = [ 8384 ];

  user.packages = with pkgs; [
    # Open Source Continuous File Synchronization
    syncthing
  ];

  services.syncthing = {
    # This is needed to allow GUI access from remote hosts
    # More information on Syncthing's firewall config can be found here:
    # https://docs.syncthing.net/users/firewall.html    services.syncthing.
    guiAddress = "0.0.0.0:8384";

    # Overrides any devices added or deleted through the WebUI
    overrideDevices = false;
    # Overrides any folders added or deleted through the WebUI
    overrideFolders = false;

    devices = {
      purple.id = "C6E5H63-KPO3NWZ-WMIY4TN-PHQGLXQ-ZLQC2WL-YOX3BG2-BIFJ6RV-O2QKWAU";
      violet.id = "ESP4NJ3-KP3QB7K-TN6G6S2-7PLQNB5-7CFQGVQ-DRICFJ2-PHGKTAO-GDHOGAR";
      lilac.id = "4K4Q7HM-KLYVORI-QPVOZKJ-7Y27FSE-DU4M4D6-5PU6HAB-ZLHJJK4-6AQVNAS";
      phone.id = "CHUU3Y7-XQ2MHGU-XYLHRQW-CZ6QW6C-WAG6R4A-XDW2Z3W-XBT7BLK-GE25KQO";
    };

    folders = {
      "phone-backups" = {
        path = "/mnt/data/backups/phone";
        devices = [ "phone" ];
      };
    };
  };
}
