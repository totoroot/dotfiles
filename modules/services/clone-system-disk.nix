{ options, config, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.clone-system-disk;
  unitName = "clone-system-disk";
  targetDisk = "/dev/sda";
  sourceDisk = "/dev/mmcblk0";
  cloneCommand = "dd if=/dev/mmcblk0 bs=8M conv=noerror,sync | pv | sudo dd of=/dev/sda";
  idleCheckScript = ''
    #!/usr/bin/env sh

    # Get load averages for comparison
    load_15=$(uptime | awk '{print $(NF)}' | sed 's/,//g')
    load_1=$(uptime | awk '{print $(NF-2)}' | sed 's/,//g')

    # Check whether host is idling
    echo "$load_1 < $load_15" | ${pkgs.bc}/bin/bc -l
  '';
in {
  options.modules.services.clone-system-disk = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    systemd.services."${unitName}" = {
      description = "Clone system disk to ${targetDisk} when system is idle";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStartPre = ''
          if ! ${idleCheckScript} ; then
            echo "Host is busy, not starting service"
            exit 1
          fi
        '';
        ExecStart = ''
          ${cloneCommand}
        '';
        RequiresMountsFor = "/dev/sda /dev/mmcblk0";
      };
    };
  };
}
