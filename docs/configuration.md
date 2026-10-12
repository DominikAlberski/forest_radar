# Configuration

## Model configuration

[config/model.yml](../config/model.yml) selects the model client.

- `client: stub` returns a fixed Polish sentence. Use it without a model host. This is the default.
- Any other value uses Ollama at `url` with the model `model`. Example: `url: http://localhost:11434`.

The model host is read from this file only. A request can never choose it. Ollama binds to localhost by default. Set `OLLAMA_HOST=0.0.0.0` on a separate model host.

## Cache limits

The server keeps source answers in memory, per browser session cookie. The limits are 256 entries and 128 MiB. A search answer lives 30 minutes. A restart clears the cache.
