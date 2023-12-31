{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.fail2ban;
in
{
  options.modules.services.fail2ban = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.etc = {
      # Define an action that will trigger a Ntfy push notification upon the issue of every new ban
      "fail2ban/action.d/ntfy.conf".text = ''
        [Definition]
        # Needed to avoid receiving a new notification after every restart
        norestored = true
        actionban = curl -H "Title: <ip> has been banned" -d "<name> jail has banned <ip> from accessing $(hostname) after <failures> attempts of hacking the system." https://ntfy.sh/JamFail2banNotifications
      '';
      "fail2ban/filter.d/nginx-probing.conf".text = ''
        [Definition]
        failregex = ^<HOST>.*GET.*(matrix/server|\.php|admin|wp\-).* HTTP/\d.\d\" 404.*$
      '';
    };

    services.fail2ban = {
      enable = true;
      # Needed to ban on IPv4 and IPv6 for all ports
      extraPackages = [ pkgs.ipset ];
      banaction = "iptables-ipset-proto6-allports";
      # Ban IP after 5 failures
      maxretry = 5;
      ignoreIP = [
        # Whitelist some subnets
        # Local subnet
        "192.168.8.0/24"
        # Tailscale subnet
        "100.64.0.0/24"
      ];
      # Ban IPs for one hour on the first ban
      bantime = "1h";
      bantime-increment = {
        # Enable increment of bantime after each violation
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        # Do not ban for more than 1 week
        maxtime = "168h";
        # Calculate the bantime based on all the violations
        overalljails = true;
      };
      jails = {
        # Maximum 6 failures in 600 seconds
        "nginx-probing" = ''
          enabled = true
          filter = nginx-probing
          logpath = /var/log/nginx/access.log
          backend = auto
          maxretry = 5
          findtime = 600
        '';
        # nginx-req-limit.settings = {
        #   enabled = true;
        #   filter = "nginx-req-limit";
        #   action = ''iptables-multiport[name=ReqLimit, port="http,https", protocol=tcp]'';
        #   logpath = "/var/log/nginx/*error.log";
        #   findtime = 600;
        #   bantime = 600;
        #   maxretry = 5;
        # };
      };
    };
  };
}
