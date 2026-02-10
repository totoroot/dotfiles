{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.blender;
in {
  options.modules.desktop.blender = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # 3D Creation/Animation/Publishing System with HIP support
      blender
    ];
  };
}
