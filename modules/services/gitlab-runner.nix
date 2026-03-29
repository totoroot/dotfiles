{ config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.gitlab-runner;
in
{
  options.modules.services.gitlab-runner = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.gitlab-runner.enable = true;
  };
}
