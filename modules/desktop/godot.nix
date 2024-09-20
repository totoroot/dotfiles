{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.godot;
in {
  options.modules.desktop.godot = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Free and Open Source 2D and 3D game engine
      godot_4
      # Free and Open Source 2D sprite editor
      pixelorama
    ];
  };
}
