# Originally based on [this article](https://grahamc.com/blog/timemachine-backups-linux-nixos/) by Graham Christensen
# (netatalk/AFP approach; no longer used here).
# Thanks to Carlos Vaz for the SMB Time Machine approach:
#   https://carlosvaz.com/posts/setting-up-samba-shares-on-nixos-with-support-for-macos-time-machine-backups/
#
# README
# - This module uses SMB (samba) for Time Machine shares, not netatalk.
# - Why: netatalk (AFP) is deprecated and less reliable with modern macOS.
#   SMB + the fruit/vfs objects + Avahi _adisk records is the current
#   supported approach for Time Machine on Linux.
# - Configure shares via modules.services.time-machine.shares:
#   [{ name = "time-machine-foo"; path = "/mnt/time-machine-foo"; user = "foo"; }]

{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.time-machine;
in
{
  options.modules.services.time-machine = {
    enable = mkBoolOpt false;
    shares = mkOption {
      type = with types; listOf (submodule ({ ... }: {
        options = {
          name = mkOption { type = str; };
          path = mkOption { type = str; };
          user = mkOption { type = str; };
          group = mkOption { type = str; default = "users"; };
          createUser = mkOption { type = bool; default = true; };
          systemUser = mkOption { type = bool; default = true; };
        };
      }));
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    services = {
      samba = {
        enable = true;
        settings =
          {
            global = {
              "workgroup" = "WORKGROUP";
              "server string" = "smbviolet";
              "netbios name" = "smbviolet";
              "security" = "user";
              "map to guest" = "bad user";
              "fruit:aapl" = "yes";
              "vfs objects" = "catia fruit streams_xattr";

              # Keep nmbd/NetBIOS browser elections disabled to avoid nmbd crashes.
              "disable netbios" = "yes";
              "local master" = "no";
              "domain master" = "no";
              "preferred master" = "no";
              "os level" = "0";

              # Only available on localhost, local network and Tailscale
              # Note: localhost is the ipv6 localhost ::1
              "hosts allow" = "100.64.0.0/10 10.0.0.0/24 127.0.0.1 localhost";
              "hosts deny" = "0.0.0.0/0";
              "guest account" = "nobody";
            };
          }
          // (builtins.listToAttrs (map (share: {
            name = share.name;
            value = {
              "path" = share.path;
              "valid users" = share.user;
              "public" = "no";
              "writeable" = "yes";
              "force user" = share.user;
              "fruit:aapl" = "yes";
              "fruit:time machine" = "yes";
              "vfs objects" = "catia fruit streams_xattr";
            };
          }) cfg.shares));
      };

      samba-wsdd = {
        enable = true;
        discovery = true;
      };

      # nmbd is legacy NetBIOS discovery and not required for SMB Time Machine.
      # Disable it to avoid crashes in browser-election code paths.
      samba.nmbd.enable = false;

      avahi = {
        enable = true;
        publish.enable = true;
        publish.userServices = true;
        nssmdns4 = true;
        nssmdns6 = false;
        # https://wiki.nixos.org/wiki/Samba#Apple_Time_Machine
        extraServiceFiles = builtins.listToAttrs (map (share: {
          name = "timemachine-${share.name}";
          value = ''
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
                <txt-record>dk0=adVN=${share.name},adVF=0x82</txt-record>
                <txt-record>sys=waMa=0,adVF=0x100</txt-record>
              </service>
            </service-group>
          '';
        }) cfg.shares);
      };
    };

    systemd.tmpfiles.rules =
      map (share: "d ${share.path} 0755 ${share.user} ${share.group}") cfg.shares;

    users.users =
      builtins.listToAttrs
        (map (share: {
          name = share.user;
          value = {
            isSystemUser = share.systemUser;
            isNormalUser = mkIf (!share.systemUser) true;
            createHome = false;
            group = share.group;
          };
        }) (builtins.filter (share: share.createUser) cfg.shares));

    users.groups =
      builtins.listToAttrs
        (map (share: {
          name = share.group;
          value = { };
        }) (builtins.filter (share: share.createUser) cfg.shares));

    # Open firewall for SMB + mDNS
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --source 10.0.0.0/24 --dport 445 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --source 100.64.0.0/10 --dport 445 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 10.0.0.0/24 --dport 5353 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --source 100.64.0.0/10 --dport 5353 -j nixos-fw-accept
    '';
  };
}
