{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.modernShell;
in
{
  options.modules.home.modernShell = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
      # cat(1) clone with syntax highlighting and Git integration
      bat
      # Replacement for 'ls' written in Rust
      eza
      # Quick command-line access to files and directories for POSIX shells
      fasd
      # Intuitive sed alternative
      sd
      # Intuitive find alternative
      fd
    ];

    home.sessionVariables = {
      FZF_DEFAULT_OPTS = "--reverse --ansi --inline-info --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4";
    };
  };
}
