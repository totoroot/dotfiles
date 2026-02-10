{ ... }:
let
  domain = "xn--berwachungsbehr-mtb1g.de";
in
{
  imports = [
    ./hardware-configuration.nix
    ./mounts.nix
  ];

  modules = {
    theme.active = "dracula";
    editors = {
      default = "micro";
      helix.enable = true;
      micro.enable = true;
      vim.enable = true;
    };
    shell = {
      aerc.enable = false;
      archive.enable = true;
      borg.enable = true;
      cli.enable = false;
      devenv.enable = false;
      devops.enable = false;
      git.enable = true;
      gnupg.enable = true;
      iperf.enable = true;
      lf.enable = true;
      nu.enable = false;
      pass.enable = true;
      utilities.enable = true;
      zsh.enable = true;
    };
    services = {
      fail2ban.enable = true;
      headscale.enable = true;
      homepage.enable = true;
      nextcloud.enable = true;
      mailserver.enable = true;
      nginx.enable = true;
      goaccess = {
        enable = true;
        logFilePath = "/var/log/nginx/access.log";
        logFileFormat = "COMBINED";
        enableNginx = true;
        nginxEnableSSL = true;
        serverHost = "zugriffs.${domain}";
        serverPath = "";
        userName = "goaccess";
      };
      ntfy.enable = true;
      # TODO Figure out build failure for n8n
      n8n.enable = false;
      plausible.enable = false;
      ssh.enable = true;
      uptime-kuma.enable = true;
      tailscale.enable = true;
      vaultwarden.enable = true;
      prometheus = {
        enable = false;
        exporters = {
          node.enable = true;
          systemd.enable = true;
          statsd.enable = true;
          smartctl.enable = false;
          blackbox.enable = false;
          nginx.enable = true;
          nginxlog.enable = true;
          fail2ban.enable = true;
          adguard.enable = false;
          fritzbox.enable = false;
          speedtest.enable = false;
        };
      };
      webmail.enable = true;
      wordpress.enable = false;
    };
  };

  # Set stateVersion
  system.stateVersion = "25.11";

  # Limit update size/frequency of rebuilds
  # Also preserve space on disk
  # See https://mastodon.online/@nomeata/109915786344697931
  documentation.nixos.enable = false;

  # NixOS networking configuration
  networking = {
    networkmanager.enable = false;
    useDHCP = true;
    interfaces."ens3" = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "45.83.104.124";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2a03:4000:46:a49::";
        prefixLength = 64;
      }];
    };
    defaultGateway =
      {
        address = "45.83.104.1";
        interface = "ens3";
      };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    nameservers = [
      "9.9.9.9"
    ];
  };

  users.users.goaccess.extraGroups = [ "nginx" ];
}
