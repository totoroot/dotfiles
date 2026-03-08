{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.ollama;
in
{
  options.modules.services.ollama = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ollama
    ];

    services.ollama.enable = true;
  };
}
