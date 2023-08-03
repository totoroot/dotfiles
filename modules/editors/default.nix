{ config, options, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors;
in {
  options.modules.editors = {
    default = mkOpt types.str "helix";
  };

  config = mkIf (cfg.default != null) {
    env.EDITOR = cfg.default;
  };
}
