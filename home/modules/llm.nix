{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.home.llm;
  basePiAgentSettings = builtins.fromJSON (builtins.readFile ../../config/pi/agent/settings.json);
  mergedPiAgentSettings = recursiveUpdate basePiAgentSettings cfg.piAgentSettingsOverride;
in
{
  options.modules.home.llm = {
    enable = mkBoolOpt false;

    piAgentSettingsOverride = mkOption {
      type = types.attrs;
      default = { };
      description = "Host-specific overrides merged into Pi agent settings.json.";
    };
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
      # Coding agent CLI with read, bash, edit, write tools and session management
      pi-coding-agent
      # Minimal CLI coding agent by Mistral
      # mistral-vibe
      # Lightweight coding agent that runs in your terminal (by NotVeryOpenAI)
      # codex
      # AI coding agent built for the terminal
      # opencode
      # Open-source, extensible AI agent that goes beyond code suggestions - install, execute, edit, and test with any LLM
      # goose-cli
    ];

    home.file = {
      ".pi/agent/settings.json".text = builtins.toJSON mergedPiAgentSettings;
    };
  };
}
