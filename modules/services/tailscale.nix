{ pkgs, options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.tailscale;
in
{
  options.modules.services.tailscale = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services = {
      tailscale = {
        enable = true;
        useRoutingFeatures = "both";
      };
    };

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # Avoid route/DNS races during early boot.
      # Wait for full network readiness and a running tailscaled daemon.
      after = [ "network-online.target" "tailscaled.service" ];
      wants = [ "network-online.target" "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];

      # Set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # Have the job run this shell script
      script = with pkgs; ''
        # Wait for tailscaled to settle
        sleep 2

        # Check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # Otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up --qr --reset --login-server https://headscale.xn--berwachungsbehr-mtb1g.de
      '';
    };

    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    user.extraGroups = [ "tailscale" ];
  };
}
