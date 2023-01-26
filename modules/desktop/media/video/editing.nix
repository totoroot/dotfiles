# modules/desktop/media/video/editing.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.video.editing;
in {
  options.modules.desktop.media.video.editing = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      # Video editor
      kdenlive

      # Professional Video Editing, Color, Effects and Audio Post
      # Issues with Radeon graphics cards
      # See this issue: https://github.com/NixOS/nixpkgs/pull/152113

      # Also package is marked as broken as of 2022-01-16
      # error: Package ‘python-2.7.18.6’ in /nix/store/ci0324339l5i3x7q68vigpfcf1jicsgs-source/pkgs/development/interpreters/python/cpython/2.7/default.nix:341 is marked as insecure, refusing to evaluate.
      # - Python 2.7 has reached its end of life after 2020-01-01. See https://www.python.org/doc/sunset-python-2/.
      # unstable.davinci-resolve

      # Node-graph based, open-source compositing software
      # FIXME Temporarily installed with flatpak due to broken Nix package
      # natron
    ];
  };
}
