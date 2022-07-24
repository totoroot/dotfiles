{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.vim;
in {
  options.modules.editors.vim = {
    enable = mkBoolOpt false;
    desktop.enable  = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      (if cfg.enable then [
        editorconfig-core-c
        unstable.neovim
      ] else []) ++

      (if cfg.desktop.enable then [
        unstable.neovide
      ] else []);

    # This is for non-neovim, so it loads my nvim config
    # env.VIMINIT = "let \\$MYVIMRC='\\$XDG_CONFIG_HOME/nvim/init.vim' | source \\$MYVIMRC";

    environment.shellAliases = {
      vim = "nvim";
    };
  };
}
