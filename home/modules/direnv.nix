{ config, ... }:

{
  programs.direnv = {
    enable = true;
    # The custom Zsh startup sources extra.zshrc instead of HM's initContent.
    enableZshIntegration = !(config.modules.home.zsh.enable or false);
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };
}
