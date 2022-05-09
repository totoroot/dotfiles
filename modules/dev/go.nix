# modules/dev/go.nix

{ config, options, lib, pkgs, my, ... }:

with lib;
with lib.my;
let cfg = config.modules.dev.go;
in {
  options.modules.dev.go = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # The Go Programming language
      unstable.go_1_18
      # Collection of tools and libraries for working with Go code, including linters and static analysis
      unstable.go-tools
      # Fast and modern static website engine
      unstable.hugo
    ];
    env.GOPATH  = "$HOME/.go";
    env.GOBIN   = "$HOME/.go/bin";
    env.PATH    = [ "$GOBIN" ];
  };
}
