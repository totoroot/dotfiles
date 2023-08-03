{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let cfg = config.modules.dev.scala;
in {
  options.modules.dev.scala = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # A general purpose programming language
      scala
      # The open-source Java Development Kit
      jdk
      # A build tool for Scala, Java and more
      sbt
    ];
  };
}
