{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.vim;
in
{
  options.modules.home.vim = {
    enable = mkBoolOpt false;
    desktop.enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        editorconfig-core-c
        # Vim text editor fork focused on extensibility and agility
        neovim
      ]
      ++ (if cfg.desktop.enable then [
        # Simple graphical user interface for Neovim
        neovide
      ] else [ ]);

    programs.zsh.shellAliases = {
      vim = "nvim";
    };
  };
}
