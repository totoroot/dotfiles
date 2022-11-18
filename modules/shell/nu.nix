{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.nu;
in {
  options.modules.shell.nu = with types; {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      nushell
    ];

    home.configFile = {
      "nushell" = { source = "${configDir}/nushell"; recursive = true; };
      "starship.toml".source = "${configDir}/starship/starship.toml";
    };
  };
}
