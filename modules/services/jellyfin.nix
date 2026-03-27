{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.jellyfin;
in
{
  options.modules.services.jellyfin = {
    enable = mkBoolOpt false;

    # Expose Jellyfin only on Tailnet by default for reverse-proxy setups.
    openFirewall = mkBoolOpt true;

    port = mkOpt types.port 8096;

    # Extra groups for the jellyfin user to access mounted media volumes.
    extraGroups = mkOpt (types.listOf types.str) [ ];
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      # Avoid opening all interfaces; we scope access via tailscale firewall rules below.
      openFirewall = false;
    };

    users.users.jellyfin.extraGroups = cfg.extraGroups;

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
