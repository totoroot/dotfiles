{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.llm;
  dotfilesDir = "${config.xdg.configHome}/dotfiles";
  piAgentContentDir = "${config.home.homeDirectory}/Development/agentic/pi-agent-content";
  hazmat = inputs."hazmat-flake".packages.${pkgs.system}.default;
  piCodingAgent = inputs."pi-coding-agent-flake".packages.${pkgs.system}.default;
in
{
  options.modules.home.llm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.home.unfreePackages = {
      enable = true;
      packageNames = [
        # Optional Rust speedups for Textual
        "textual-speedups"
      ];
    };

    home.packages = with pkgs; [
      # Get up and running with large language models locally
      ollama
      # Terminal tool that right-sizes LLM models to your system's RAM, CPU, and GPU
      llmfit
      # Minimal CLI coding agent by Mistral
      # mistral-vibe
      # Lightweight coding agent that runs in your terminal (by NotVeryOpenAI)
      # codex
      # AI coding agent built for the terminal
      opencode
      # Linux virtual machines with automatic file sharing and port forwarding
      lima
      # macOS containment for AI agents
      hazmat
      # Interactive coding agent CLI from the Pi monorepo
      piCodingAgent
    ];

    home.file = {
      ".pi/agent/AGENTS.md".source =
        config.lib.file.mkOutOfStoreSymlink "${piAgentContentDir}/AGENTS.md";
      ".pi/agent/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/config/pi/agent/settings.json";
      ".pi/agent/themes/dracula.json".source =
        config.lib.file.mkOutOfStoreSymlink "${piAgentContentDir}/themes/dracula.json";
    };
  };
}
