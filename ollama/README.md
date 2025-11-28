# Ollama - Headless Environment

A composable, headless Ollama environment for running large language models locally with CUDA support. Perfect for automation, CI/CD pipelines, and composed workflows.

## Features

- 🎯 **Headless Configuration** - Environment variable-based setup
- 🚀 **Service-Based** - Ollama server runs as a managed service
- 🔧 **Runtime Configurability** - Override any setting at activation time
- 🎮 **CUDA Acceleration** - GPU-enabled inference on Linux systems
- 📦 **Composable** - Designed to be included in other environments
- 🌐 **Cross-Platform** - CUDA for Linux, regular Ollama for macOS
- ⚡ **Zero Interaction** - Perfect for automation and scripting

## Quick Start

### 1. Activate the Environment

```bash
cd ollama-headless
flox activate
```

### 2. Download a Model

```bash
ollama pull llama2
# or smaller models:
ollama pull llama2:7b
ollama pull phi
ollama pull tinyllama
```

### 3. Start the Service

```bash
flox activate -s
```

### 4. Test the API

```bash
ollama-health
# or
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Why is the sky blue?"
}'
```

## Environment Variables

All configuration is done via environment variables with sensible defaults.

### Server Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_HOST` | `127.0.0.1:11434` | Server bind address |
| `OLLAMA_MODELS` | `$FLOX_ENV_CACHE/models` | Model storage directory |
| `OLLAMA_ORIGINS` | *(Ollama defaults)* | CORS allowed origins |

### Performance & Memory

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_CONTEXT_LENGTH` | `4096` | Default context window size (tokens) |
| `OLLAMA_KEEP_ALIVE` | `5m` | How long models stay loaded in memory |
| `OLLAMA_MAX_LOADED_MODELS` | *auto* | Max concurrent loaded models (3 × GPU count) |
| `OLLAMA_NUM_PARALLEL` | `1` | Max parallel requests per model |
| `OLLAMA_MAX_QUEUE` | `512` | Max queued requests before rejection |
| `OLLAMA_LOAD_TIMEOUT` | `5m` | Timeout for model loading |

### GPU Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_FLASH_ATTENTION` | *disabled* | Enable Flash Attention (experimental) |
| `OLLAMA_KV_CACHE_TYPE` | `f16` | K/V cache quantization (`f16`, `q8_0`, `q4_0`) |
| `OLLAMA_GPU_OVERHEAD` | `0` | Reserve VRAM per GPU (bytes) |
| `CUDA_VISIBLE_DEVICES` | *all* | Limit visible GPUs (e.g., `0,1`) |

### Advanced / Experimental

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_DEBUG` | `0` | Enable debug logging (`1` = enabled) |
| `OLLAMA_SCHED_SPREAD` | *disabled* | Schedule models across all GPUs |
| `OLLAMA_NOPRUNE` | *disabled* | Don't prune model blobs on startup |
| `OLLAMA_LLM_LIBRARY` | *auto* | Bypass LLM library autodetection |
| `OLLAMA_AUTH` | *disabled* | Enable client-server authentication (experimental) |

## Usage Examples

### Basic Activation (Localhost Only)

```bash
flox activate -s
# Ollama listens on 127.0.0.1:11434
```

### Network Accessible

```bash
OLLAMA_HOST=0.0.0.0:11434 flox activate -s
# Ollama listens on all interfaces
```

### Custom Port

```bash
OLLAMA_HOST=127.0.0.1:8080 flox activate -s
# Ollama listens on port 8080
```

### High Performance

```bash
OLLAMA_NUM_PARALLEL=4 OLLAMA_KEEP_ALIVE=30m flox activate -s
# 4 parallel requests, models stay loaded for 30 minutes
```

### Debug Mode

```bash
OLLAMA_DEBUG=1 flox activate -s
# Verbose logging enabled
```

### Limit GPU

```bash
CUDA_VISIBLE_DEVICES=0 flox activate -s
# Only use GPU 0
```

### Multiple Overrides

```bash
OLLAMA_HOST=0.0.0.0:8080 \
OLLAMA_NUM_PARALLEL=4 \
OLLAMA_CONTEXT_LENGTH=8192 \
flox activate -s
```

## Commands

### Configuration

```bash
ollama-info              # Show current configuration
ollama-health            # Test API endpoint health
```

### Model Management

```bash
ollama pull <model>      # Download a model
ollama list              # List local models
ollama ps                # List running models
ollama rm <model>        # Remove a model
ollama show <model>      # Show model information
```

### Service Management

```bash
flox services start              # Start Ollama service
flox services status             # Check service status
flox services logs ollama        # View Ollama logs
flox services stop               # Stop all services
flox services restart            # Restart all services
```

### API Testing

```bash
# Health check
curl http://localhost:11434/

# Generate completion
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Tell me a joke",
  "stream": false
}'

# Chat completion
curl http://localhost:11434/api/chat -d '{
  "model": "llama2",
  "messages": [
    {"role": "user", "content": "What is 2+2?"}
  ]
}'

# List models
curl http://localhost:11434/api/tags
```

## Model Management

### Popular Models

| Model | Size | Use Case |
|-------|------|----------|
| `llama2:7b` | ~3.8GB | General purpose, fast |
| `llama2` | ~3.8GB | Alias for llama2:7b |
| `phi` | ~1.6GB | Small, efficient |
| `mistral` | ~4.1GB | High quality |
| `codellama` | ~3.8GB | Code generation |
| `tinyllama` | ~637MB | Very fast, minimal |
| `llama2:13b` | ~7.4GB | Better quality |
| `llama2:70b` | ~40GB | Best quality (requires lots of VRAM) |

### Storage Locations

**Default:** `$FLOX_ENV_CACHE/models` (isolated per environment)

**Override:**
```bash
OLLAMA_MODELS=/mnt/models flox activate -s
```

### Model Size Planning

Estimate VRAM requirements:
- **7B parameters:** ~4-6GB VRAM
- **13B parameters:** ~8-10GB VRAM
- **70B parameters:** ~40-48GB VRAM

**Context length impact:**
- Larger context = more VRAM
- Use `OLLAMA_CONTEXT_LENGTH` to limit if needed

## Composition Examples

### Example 1: RAG Application with PostgreSQL

```toml
# .flox/env/manifest.toml
[include]
environments = [
  { dir = "../ollama-headless" },
  { dir = "../postgres-headless" },
]

[hook]
on-activate = '''
echo "RAG Application Environment Ready"
echo ""
echo "Ollama: http://localhost:11434"
echo "Postgres: localhost:5432"
'''
```

### Example 2: Agent Framework with Redis

```toml
[include]
environments = [
  { dir = "../ollama-headless" },
  { dir = "../redis-headless" },
]
```

### Example 3: Development Stack

```toml
[include]
environments = [
  { dir = "../ollama-headless" },
  { dir = "../python312" },
]

[vars]
OLLAMA_API_BASE = "http://localhost:11434"
```

### Example 4: Custom Configuration

```toml
[include]
environments = [
  { dir = "../ollama-headless" },
]

[vars]
OLLAMA_HOST = "0.0.0.0:8080"
OLLAMA_NUM_PARALLEL = "4"
OLLAMA_CONTEXT_LENGTH = "8192"
```

## API Reference

### Key Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Health check |
| `/api/generate` | POST | Generate completion |
| `/api/chat` | POST | Chat completion |
| `/api/tags` | GET | List models |
| `/api/show` | POST | Show model info |
| `/api/pull` | POST | Download model |
| `/api/delete` | DELETE | Remove model |
| `/api/ps` | GET | List running models |
| `/api/embeddings` | POST | Generate embeddings |

### Generate Endpoint

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Why is the sky blue?",
  "stream": false,
  "options": {
    "temperature": 0.7,
    "top_p": 0.9
  }
}'
```

### Chat Endpoint

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama2",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is 2+2?"}
  ],
  "stream": false
}'
```

## Performance Tuning

### For Maximum Throughput

```bash
OLLAMA_NUM_PARALLEL=8 \
OLLAMA_KEEP_ALIVE=1h \
OLLAMA_FLASH_ATTENTION=1 \
flox activate -s
```

### For Low Memory

```bash
OLLAMA_CONTEXT_LENGTH=2048 \
OLLAMA_KV_CACHE_TYPE=q8_0 \
OLLAMA_KEEP_ALIVE=1m \
flox activate -s
```

### For Multi-GPU

```bash
OLLAMA_SCHED_SPREAD=1 \
OLLAMA_MAX_LOADED_MODELS=6 \
flox activate -s
```

### For Long Context

```bash
OLLAMA_CONTEXT_LENGTH=32768 \
OLLAMA_FLASH_ATTENTION=1 \
OLLAMA_GPU_OVERHEAD=2147483648 \
flox activate -s
```

## Troubleshooting

### Check Service Status

```bash
flox services status
```

### View Logs

```bash
flox services logs ollama
```

### Test API Health

```bash
ollama-health
# or
curl http://localhost:11434/
```

### Check GPU Detection

```bash
# Start with debug logging
OLLAMA_DEBUG=1 flox activate -s

# View logs for GPU info
flox services logs ollama | grep -i gpu
```

### Common Issues

**"Ollama API is not responding"**
```bash
# Check service is running
flox services status

# Check logs for errors
flox services logs ollama

# Restart service
flox services restart
```

**"Model not found"**
```bash
# List available models
ollama list

# Pull the model
ollama pull llama2
```

**"Out of memory"**
```bash
# Use smaller model
ollama pull tinyllama

# Reduce context length
OLLAMA_CONTEXT_LENGTH=2048 flox activate -s

# Enable quantized cache
OLLAMA_KV_CACHE_TYPE=q8_0 flox activate -s
```

**"CUDA not detected"**
```bash
# Verify NVIDIA GPU
nvidia-smi

# Check CUDA libraries
flox activate -- ldd $(which ollama) | grep cuda

# Try explicit library
OLLAMA_LLM_LIBRARY=cuda flox activate -s
```

### Performance Issues

```bash
# Enable debug logging
OLLAMA_DEBUG=1 flox activate -s

# Monitor memory usage
nvidia-smi -l 1

# Check model load time
flox services logs ollama | grep "model loaded"
```

## Security Considerations

### Production Deployment

**1. Restrict network access:**
```bash
OLLAMA_HOST=127.0.0.1:11434 flox activate -s
# Use reverse proxy for external access
```

**2. Enable authentication (experimental):**
```bash
OLLAMA_AUTH=1 flox activate -s
```

**3. Limit CORS origins:**
```bash
OLLAMA_ORIGINS="https://example.com" flox activate -s
```

### Model Storage

Models are stored in `$FLOX_ENV_CACHE/models` by default, isolated per environment.

**To share models across environments:**
```bash
OLLAMA_MODELS=/shared/models flox activate -s
```

## Platform-Specific Notes

### Linux (CUDA)

- Uses `ollama-cuda` custom flake for RTX 5090 (Blackwell) support
- Auto-detects CUDA GPUs
- Includes 1.2GB `libggml-cuda.so` library
- Supports CUDA 12.5+

### macOS

- Uses standard `ollama` package from nixpkgs
- CPU-only inference
- Metal GPU acceleration (automatic)

## Related Environments

- **postgres-headless** - PostgreSQL database for RAG applications
- **redis-headless** - Redis for caching and queuing
- **python312** - Python development environment

## Resources

- [Ollama Documentation](https://docs.ollama.com/)
- [Ollama GitHub](https://github.com/ollama/ollama)
- [Ollama Models Library](https://ollama.com/library)
- [Ollama API Reference](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Ollama FAQ](https://docs.ollama.com/faq)

## Support

For issues with this Flox environment:
- Check the main README at the repository root
- Review the manifest: `.flox/env/manifest.toml`

For Ollama-specific issues:
- [Ollama Documentation](https://docs.ollama.com/)
- [Ollama GitHub Issues](https://github.com/ollama/ollama/issues)
