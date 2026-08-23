{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.fail2ban;
  bannedIpsCollector = pkgs.writeText "fail2ban-banned-ips.py" ''
    #!${pkgs.python3}/bin/python3
    import ipaddress
    import os
    import re
    import subprocess
    import sys
    import tempfile

    fail2ban_client = "${pkgs.fail2ban}/bin/fail2ban-client"
    output_path = "/var/lib/fail2ban-prometheus/f2b-banned-ips.prom"

    def command(*args):
        return subprocess.run(
            [fail2ban_client, *args], check=True, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        ).stdout

    try:
        status = command("status")
        jail_list = re.search(r"Jail list:\\s*(.*)", status)
        jails = [] if jail_list is None else [jail.strip() for jail in jail_list.group(1).split(",")]

        metrics = [
            "# HELP f2b_banned_ip Whether an IP is currently banned by Fail2ban.",
            "# TYPE f2b_banned_ip gauge",
        ]
        for jail in jails:
            for token in command("get", jail, "banip").replace(",", " ").split():
                try:
                    ip = str(ipaddress.ip_address(token.strip("[]()")))
                except ValueError:
                    continue
                metrics.append(f'f2b_banned_ip{{jail="{jail}",ip="{ip}"}} 1')

        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with tempfile.NamedTemporaryFile(
            mode="w", dir=os.path.dirname(output_path), delete=False
        ) as metric_file:
            metric_file.write("\\n".join(metrics) + "\\n")
            os.replace(metric_file.name, output_path)
    except subprocess.CalledProcessError as error:
        print(error.stderr, file=sys.stderr, end="")
        sys.exit(error.returncode)
  '';
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
        # Match specific probe signatures only. Do not ban ordinary Nextcloud
        # DAV or application requests just because a PHP-backed endpoint is 404.
        failregex = ^<HOST>.*GET.*(matrix/server|wp\-|xmlrpc\.php|phpmyadmin|adminer).* HTTP/\d.\d\" 404.*$
      '';
      # SSH invalid-user jail (ban any user != mathym).
      # "fail2ban/filter.d/sshd-invalid-user.conf".text = ''
      #   [Definition]
      #   failregex = ^%(__prefix_line)sInvalid user (?!mathym\b).*$\n            ^%(__prefix_line)sFailed password for invalid user (?!mathym\b).*$\n            ^%(__prefix_line)sFailed publickey for invalid user (?!mathym\b).*$\n            ^%(__prefix_line)sUser not known to the underlying authentication module for user (?!mathym\b).*$\n      #   ignoreregex =
      # '';
    };

    services.fail2ban = {
      enable = true;
      extraPackages = [ pkgs.ipset ];
      # Restrict bans to the affected service ports. A web-probing ban must
      # never prevent SSH recovery from a changing public IP address.
      banaction = "iptables-ipset-proto6";
      # Ban IP after 5 failures
      maxretry = 5;
      ignoreIP = [
        # Whitelist some subnets
        # Local subnet
        "192.168.0.0/24"
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
          port = http,https
          maxretry = 5
          findtime = 600
        '';
        # SSH invalid-user jail (ban any user != mathym).
        # "sshd-invalid-user" = ''
        #   enabled = true
        #   filter = sshd-invalid-user
        #   backend = systemd
        #   journalmatch = _SYSTEMD_UNIT=sshd.service
        #   maxretry = 1
        #   findtime = 600
        # '';
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

    # The packaged Fail2ban exporter reports only aggregate ban counts. Export
    # the live jail/IP membership through node_exporter's textfile collector.
    services.prometheus.exporters.node.extraFlags = [
      "--collector.textfile.directory=/var/lib/fail2ban-prometheus"
    ];
    systemd.tmpfiles.rules = [ "d /var/lib/fail2ban-prometheus 0750 root root -" ];
    systemd.services.fail2ban-banned-ips = {
      description = "Export current Fail2ban banned IPs for Prometheus";
      after = [ "fail2ban.service" ];
      requires = [ "fail2ban.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.python3}/bin/python3 ${bannedIpsCollector}";
      };
    };
    systemd.timers.fail2ban-banned-ips = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "30s";
        Persistent = true;
      };
    };
  };
}
