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
    firefoxProfileDirectory = "recovered-iml5duog.cOKXLZF1";
    enableBitwarden = false;
    enableContainers = true;
    enableGhostty = true;
  };

  # Use the signed upstream app for reliable macOS LaunchServices support.
  # Home Manager still manages the profile files, but not the Firefox app.
  modules.home.firefox.installPackage = false;

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
}
