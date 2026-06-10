{ config, pkgs, ... }:

let
  configDir = "$HOME/.config";
in
{
  home = {
    username = "matthias.thym";
    stateVersion = "25.11";
  };

  imports = [
    ../../../home/modules/home-manager-applications-fix.nix
    ../../../home/bridge.nix
    ./packages.nix
  ];

  modules.home.darwinCommon = {
    enable = true;
    hostName = "ATGRZMBP43";
    defaultUser = "mathym";
    firefoxProfileDirectory = "lxyotzh1.default";
    enableBitwarden = false;
    enableContainers = true;
    enableGhostty = true;
  };

  modules.home.gitlab-cli.enable = true;

  modules.home.llm.piAgentSettingsOverride = {
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.4";
  };

  programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
