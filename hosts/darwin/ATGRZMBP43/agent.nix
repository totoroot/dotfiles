{ ... }:
{
  # Host-specific agent settings override for MBP43
  # Keep older provider/model for this host while others use newer defaults
  config.pi.agent.settings = {
    defaultProvider = "openai-codex";
    defaultModel = "gpt-5.4";
  };
}
