{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.mullvad;
  boolToOnOff = v: if v then "on" else "off";
  boolToAllowBlock = v: if v then "allow" else "block";
in
{
  options.modules.services.mullvad = {
    enable = mkBoolOpt false;

    accountNumberFile = mkOpt types.path "/var/secrets/mullvad-account-number";

    autoConnect = mkBoolOpt true;
    connectOnBoot = mkBoolOpt true;
    lanAccess = mkBoolOpt true;
    lockdownMode = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ mullvad-vpn ];

    networking.wireguard.enable = true;
    networking.iproute2.enable = true;
    networking.firewall.checkReversePath = "loose";

    services.mullvad-vpn.enable = true;

    systemd.services.mullvad-setup = {
      description = "Configure Mullvad account and runtime settings";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "mullvad-daemon.service"
        "tailscaled.service"
        "tailscale-autoconnect.service"
      ];
      wants = [
        "network-online.target"
        "mullvad-daemon.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = [ "${pkgs.coreutils}/bin/sleep 4" ];
      };
      script = ''
        set -euo pipefail

        acct_file='${toString cfg.accountNumberFile}'
        if [ ! -r "$acct_file" ]; then
          echo "Mullvad account number file not readable: $acct_file" >&2
          exit 1
        fi

        account_number="$(${pkgs.coreutils}/bin/tr -d '[:space:]' < "$acct_file")"
        if [ -z "$account_number" ]; then
          echo "Mullvad account number is empty" >&2
          exit 1
        fi

        current_account=""
        if ${pkgs.mullvad-vpn}/bin/mullvad account get >/tmp/mullvad-account.out 2>/dev/null; then
          current_account="$(${pkgs.gnugrep}/bin/grep -Eo '[0-9]{10,}' /tmp/mullvad-account.out || true)"
        fi

        if [ "$current_account" != "$account_number" ]; then
          ${pkgs.mullvad-vpn}/bin/mullvad account login "$account_number"
        fi

        ${pkgs.mullvad-vpn}/bin/mullvad auto-connect set ${boolToOnOff cfg.autoConnect}
        ${pkgs.mullvad-vpn}/bin/mullvad lan set ${boolToAllowBlock cfg.lanAccess}
        ${pkgs.mullvad-vpn}/bin/mullvad lockdown-mode set ${boolToOnOff cfg.lockdownMode}

        if [ "${if cfg.connectOnBoot then "1" else "0"}" = "1" ]; then
          ${pkgs.mullvad-vpn}/bin/mullvad connect || true
        fi
      '';
    };
  };
}
