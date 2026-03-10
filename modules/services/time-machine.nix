# Based on [this article](https://grahamc.com/blog/timemachine-backups-linux-nixos/) by Graham Christensen

{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.time-machine;
  user = "samba";
in
{
  options.modules.services.time-machine = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      samba = {
        enable = true;
        settings = {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "smbviolet";
            "netbios name" = "smbviolet";
            "security" = "user";

            # Only available on localhost, local network and Tailscale
            # Note: localhost is the ipv6 localhost ::1
            "hosts allow" = "100.64.0.0/10 10.0.0.0/24 127.0.0.1 localhost";
            "hosts deny" = "0.0.0.0/0";
            "guest account" = "nobody";
            "map to guest" = "bad user";
          };
        };
      };

      samba-wsdd = {
        enable = true;
        discovery = true;
      };

      avahi = {
        enable = true;
        publish.enable = true;
        publish.userServices = true;
        nssmdns4 = true;
        # https://wiki.nixos.org/wiki/Samba#Apple_Time_Machine
        extraServiceFiles = {
          timemachine = ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">%h</name>
              <service>
                <type>_smb._tcp</type>
                <port>445</port>
              </service>
                <service>
                <type>_device-info._tcp</type>
                <port>0</port>
                <txt-record>model=TimeCapsule8,119</txt-record>
              </service>
              <service>
                <type>_adisk._tcp</type>
                <txt-record>dk0=adVN=time-machine-thistle,adVF=0x82</txt-record>
                <txt-record>sys=waMa=0,adVF=0x100</txt-record>
              </service>
            </service-group>
          '';
        };
      };
    };

    # Set up password: https://wiki.nixos.org/wiki/Samba#User_Authentication
    users.users.${user}.isNormalUser = true;

    # Open firewall for Samba
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --source 10.0.0.0/24 --dport 139 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --source 10.0.0.0/24 --dport 445 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --source 100.64.0.0/10 --dport 139 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --source 100.64.0.0/10 --dport 445 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 10.0.0.0/24 --dport 137 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 10.0.0.0/24 --dport 138 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 100.64.0.0/10 --dport 137 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 100.64.0.0/10 --dport 138 -j nixos-fw-accept
    '';
  };
}
