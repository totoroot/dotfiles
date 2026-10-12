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
  modules.home.qownnotes.enable = true;

  modules.home.firefox.settings = {
    "browser.nova.enabled" = false;
  };

  modules.home.llm.piAgentSettingsOverride = {
    defaultProvider = "openai-codex";
    defaultModel = "gpt-6-luna";
    defaultThinkingLevel = "medium";
    scopedModels = [
      "gpt-5.6-luna"
      "gpt-5.6-sol"
      "gpt-5.6-terra"
    ];
  };

  programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  modules.home.zsh.rcInit = ''
    if command -v direnv >/dev/null 2>&1; then
      eval "$(direnv hook zsh)"
    fi
  '';
}
