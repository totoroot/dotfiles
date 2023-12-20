{ config, options, lib, ... }:

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
    services.fail2ban = {
      enable = true;
      extraPackages = [];
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
        # apache-nohome-iptables.settings = {
        #   # Block an IP address if it accesses a non-existent
        #   # home directory more than 5 times in 10 minutes,
        #   # since that indicates that it's scanning.
        #   filter = "apache-nohome";
        #   action = ''iptables-multiport[name=HTTP, port="http,https"]'';
        #   logpath = "/var/log/httpd/error_log*";
        #   backend = "auto";
        #   findtime = 600;
        #   bantime  = 600;
        #   maxretry = 5;
        # };
        # dovecot.settings = {
        #   # block IPs which failed to log-in
        #   # aggressive mode add blocking for aborted connections
        #   filter = "dovecot[mode=aggressive]";
        #   maxretry = 3;
        # };
      };
    };

    systemd.services."fail2ban-exporter" = {
      enable = true;
      description = "Fail2ban metric exporter for Prometheus";
      documentation = [ "https://gitlab.com/hectorjsmith/fail2ban-prometheus-exporter/-/blob/main/README.md" ];
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        # See this example
        # https://gitlab.com/hectorjsmith/fail2ban-prometheus-exporter/-/blob/main/_examples/systemd/fail2ban_exporter.service?ref_type=heads
        ExecStart = "/home/mathym/fail2ban-exporter/fail2ban_exporter";
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        User = "root";
        Group = "root";
      };
    };

    networking.firewall.allowedTCPPorts = [ 9191 ];
  };
}
