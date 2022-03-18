{ pkgs, ... }:
{
  # This is needed to allow GUI access from remote hosts
  # More information on Syncthing's firewall config can be found here:
  # https://docs.syncthing.net/users/firewall.html
  services.syncthing.guiAddress = "0.0.0.0:8384";

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
}
