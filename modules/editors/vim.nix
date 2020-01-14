# When I'm stuck in the terminal or don't have access to Emacs, (neo)vim is my
# go-to. I am a vimmer at heart, after all.

{ config, lib, pkgs, ... }:
{
  my = {
    packages = with pkgs; [
      editorconfig-core-c
      neovim
    ];

    env.EDITOR = "nvim";
    env.VIMINIT = "let \\$MYVIMRC='\\$XDG_CONFIG_HOME/nvim/init.vim' | source \\$MYVIMRC";

    # My vim config is too stateful to manage with nix
    init = ''
      if [ ! -d "$XDG_CONFIG_HOME/nvim" ]; then
        ${pkgs.git}/bin/git clone https://github.com/hlissner/.vim "$XDG_CONFIG_HOME/nvim"
      fi
    '';
  };
}
