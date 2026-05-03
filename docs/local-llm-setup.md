# Local LLM Setup

Running local models via [Ollama](https://ollama.com) for use with pi-coding-agent.

## System

- **Hardware:** Apple M4 Pro, 24GB unified memory
- **Runtime:** Ollama (Metal backend)
- **Tool:** [llmfit](https://github.com/ggml-org/llmfit) for model compatibility analysis

## Installed Models

| Model | Size | Memory | Use Case |
|-------|------|--------|----------|
| `qwen2.5-coder:3b` | 1.9 GB | ~1.6 GB | Light coding tasks, fast responses |
| `qwen2.5-coder:7b` | 4.7 GB | ~4.7 GB | General coding, harder tasks |
| `ministral-3:8b` | 6.0 GB | ~6 GB | General purpose, newer architecture |

## pi-coding-agent Integration

Config: `~/.pi/agent/models.json`

```json
{
  "providers": {
    "ollama": {
      "baseUrl": "http://localhost:11434/v1",
      "api": "openai-completions",
      "apiKey": "ollama",
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false
      },
      "models": [
        { "id": "qwen2.5-coder:3b", "name": "Qwen 2.5 Coder 3B (Local)", "input": ["text"] },
        { "id": "qwen2.5-coder:7b", "name": "Qwen 2.5 Coder 7B (Local)", "input": ["text"] },
        { "id": "ministral-3:8b", "name": "Ministral 3 8B (Local)", "input": ["text"] }
      ]
    }
  }
}
```

Compat flags: Ollama doesn't support `developer` role or `reasoning_effort` param, so we use system messages instead.

Reload: Config reloads automatically when opening `/model`. No restart needed.

## Finding Models with llmfit

### Check system specs
```bash
llmfit system
```

### Recommend models for your hardware
```bash
llmfit recommend --limit 10
```

### Search for specific models
```bash
llmfit search qwen
llmfit search mistral
```

### Detailed model info
```bash
llmfit info <model-name>
```

### Filter by available memory
```bash
llmfit --memory 12G recommend --limit 10
```

## Adding New Models

1. Find model in Ollama library or on HuggingFace
2. Check compatibility with `llmfit`
3. Pull model:
   ```bash
   ollama pull <model-name>
   ```
4. Add to `~/.pi/agent/models.json`
5. Select via `/model` in pi

## Ollama Commands

```bash
ollama list              # Show installed models
ollama ps               # Show running models
ollama rm <model>       # Delete model
ollama pull <model>     # Download model
```

## Notes

- Ollama runs at `http://localhost:11434/v1` (OpenAI-compatible API)
- Models load into unified memory — no separate VRAM
- llmfit recommends MLX-quantized models for Apple Silicon, but Ollama uses its own quantization
- Download speeds vary; use `nohup` for large models:
  ```bash
  nohup ollama pull <model> > /tmp/ollama-pull.log 2>&1 &
  tail -f /tmp/ollama-pull.log
  ```
