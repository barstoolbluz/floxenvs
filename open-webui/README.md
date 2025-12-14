# 🤖 Open WebUI + Ollama

A beautiful web interface for local LLMs, powered by Open WebUI and Ollama with GPU acceleration.

## ✨ What You Get

- **Beautiful Chat Interface** - Open WebUI's polished UI for interacting with LLMs
- **Local LLMs** - Run models completely offline with Ollama
- **GPU Acceleration** - CUDA support on Linux for fast inference
- **One-Command Setup** - Both services start together
- **Privacy First** - All telemetry disabled, data stays local
- **Model Library** - Access to Ollama's entire model catalog

## 🚀 Quick Start

```bash
# Navigate to environment
cd /home/daedalus/dev/floxenvs/open-webui

# Start everything
flox activate -s

# Open browser
# http://localhost:8080
```

That's it! Open WebUI is now running with Ollama backend.

## 📦 Download Models

### Popular Models

```bash
ollama pull llama3.2:3b      # Fast, general purpose (3GB)
ollama pull mistral:7b       # Excellent for coding (4GB)
ollama pull phi3:mini         # Tiny but capable (2GB)
ollama pull codellama:7b      # Specialized for code (4GB)

# List available models
ollama list
```

### Model Management

```bash
# Show running models
ollama ps

# Remove a model
ollama rm <model>

# Copy and customize
ollama cp llama3.2:3b mycustom
```

## 🛠️ Helper Commands

Once activated, these commands are available:

| Command | Description |
|---------|-------------|
| `webui_info` | Display configuration and URLs |
| `webui_status` | Check service status |
| `webui_logs` | Tail Open WebUI logs |
| `ollama_status` | Test Ollama connectivity |
| `ollama list` | List downloaded models |
| `ollama pull <model>` | Download a model |
| `ollama ps` | Show running models |
| `flox services status` | Show all services |
| `flox services logs <service>` | View service logs |

## ⚙️ Configuration

### Default Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `HOST` | `0.0.0.0` | Open WebUI bind address |
| `PORT` | `8080` | Open WebUI port |
| `OLLAMA_BASE_URL` | `http://127.0.0.1:11434` | Ollama API endpoint |
| `DATA_DIR` | `$FLOX_ENV_CACHE/openwebui/data` | Database and uploads |
| `CACHE_DIR` | `$FLOX_ENV_CACHE/openwebui/cache` | Model cache |

### Runtime Overrides

Override any setting at runtime:

```bash
# Different port
PORT=3000 flox activate -s

# Remote Ollama server
OLLAMA_BASE_URL=http://192.168.1.100:11434 flox activate -s

# Project-local models
OLLAMA_MODELS=$FLOX_ENV_CACHE/models flox activate -s

# Custom data directory
DATA_DIR=~/.open-webui/data flox activate -s

# Multiple overrides
PORT=8081 OLLAMA_HOST=0.0.0.0:11435 flox activate -s
```

## 📁 Data Persistence

All data is stored in `$FLOX_ENV_CACHE/openwebui/`:

```
openwebui/
├── data/                    # SQLite database, user uploads
│   ├── webui.db            # Chat history, settings
│   └── uploads/            # Uploaded files
├── cache/                   # Model caches
│   ├── huggingface/        # HF models
│   ├── sentence_transformers/
│   ├── tiktoken/
│   └── whisper/            # Speech models
└── webui_secret_key        # Auto-generated security key
```

### Backup & Restore

```bash
# Backup entire environment data
tar -czf openwebui-backup.tar.gz $FLOX_ENV_CACHE/openwebui/

# Restore
tar -xzf openwebui-backup.tar.gz -C $FLOX_ENV_CACHE/
```

## 🎮 GPU Support

### NVIDIA GPUs (Linux)

GPU acceleration is automatic if:
1. NVIDIA drivers are installed
2. GPU is CUDA-capable
3. `nvidia-smi` is available

Check GPU status:
```bash
nvidia-smi                    # Should show your GPU
ollama ps                     # Shows "GPU" under PROCESSOR when running
```

### macOS

Uses Metal acceleration automatically on Apple Silicon.

### Disable GPU

Force CPU-only mode:
```bash
CUDA_VISIBLE_DEVICES="" flox activate -s
```

## 🔧 Troubleshooting

### Services Won't Start

```bash
# Check service status
flox services status

# View detailed logs
flox services logs openwebui
flox services logs ollama

# Restart services
flox services restart openwebui
flox services restart ollama
```

### Port Already in Use

```bash
# Check what's using the port
lsof -i :8080

# Use different port
PORT=8081 flox activate -s
```

### GPU Not Detected

```bash
# Verify GPU is visible
nvidia-smi

# Check Ollama GPU detection
ollama ps  # Should show GPU when model is loaded

# View Ollama debug info
OLLAMA_DEBUG=1 flox activate -s
```

### Connection Issues

```bash
# Test Ollama connectivity
ollama_status
curl http://localhost:11434/api/tags

# Check if services are running
flox services status

# Ensure Ollama is accessible
OLLAMA_HOST=0.0.0.0:11434 flox activate -s
```

### Reset Environment

```bash
# Stop all services
flox services stop

# Clear all data (WARNING: deletes chats and settings)
rm -rf $FLOX_ENV_CACHE/openwebui/

# Restart fresh
flox activate -s
```

## 🚀 Advanced Usage

### Multiple Instances

Run multiple environments with different configs:

```bash
# Development instance
PORT=8080 DATA_DIR=~/.openwebui-dev flox activate -s

# Production instance (in another terminal)
PORT=8081 DATA_DIR=~/.openwebui-prod flox activate -s
```

### Remote Access

Allow access from other devices on your network:

```bash
# Listen on all interfaces
HOST=0.0.0.0 PORT=8080 flox activate -s

# Access from another device
# http://<your-ip>:8080

# Security: Use reverse proxy with SSL for production
```

### Custom Models

Create and use custom Ollama models:

```bash
# Create Modelfile
cat > Modelfile << 'EOF'
FROM llama3.2:3b
SYSTEM "You are a helpful coding assistant specialized in Python."
TEMPERATURE 0.7
TOP_P 0.9
EOF

# Create custom model
ollama create myassistant -f Modelfile

# Use in Open WebUI
# Select "myassistant" from the model dropdown
```

### API Access

Open WebUI and Ollama both provide APIs:

```bash
# Ollama API
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Hello!"
}'

# Open WebUI API (requires API key from settings)
curl http://localhost:8080/api/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"model": "llama3.2:3b", "messages": [{"role": "user", "content": "Hello!"}]}'
```

## 🎯 Features

- ✅ **Composable** - Includes `barstoolbluz/ollama` environment
- ✅ **Cross-platform** - Linux (with CUDA) and macOS support
- ✅ **Persistent** - Chat history and settings preserved
- ✅ **Secure** - Secret key auto-generated, telemetry disabled
- ✅ **Flexible** - All settings configurable via environment variables
- ✅ **Service Management** - Automatic startup and monitoring
- ✅ **Model Caching** - Efficient model storage and loading

## 🔒 Security Notes

- **Secret Key**: Auto-generated on first run, stored in `webui_secret_key`
- **Telemetry**: All analytics and tracking disabled by default
- **Network**: Binds to all interfaces by default - restrict with `HOST=127.0.0.1` for local-only
- **Data**: All data stored locally, nothing sent to external servers
- **Authentication**: Open WebUI supports user accounts and API keys

## 📋 Environment Details

### Included Packages
- `open-webui` v0.6.40 (pinned version)
- `ollama-cuda` (Linux) / `ollama` (macOS) - latest from Flox catalog
- Ollama environment from `barstoolbluz/ollama`
- Additional utilities: `bat`, `curl`

### Supported Platforms
- Linux x86_64 (with CUDA support)
- Linux ARM64 (with CUDA support)
- macOS x86_64
- macOS ARM64 (Apple Silicon)

### Service Configuration

Both services run as Flox-managed services:
- **Open WebUI**: Logs to `$FLOX_ENV_CACHE/logs/openwebui.log`
- **Ollama**: Inherits configuration from composed environment

## 🤝 Contributing

This environment is managed in Git. To contribute:

1. Fork/clone the repository
2. Make changes to `.flox/env/manifest.toml`
3. Test thoroughly: `flox activate -s`
4. Submit changes

### Development Tips

```bash
# Test manifest changes
flox edit  # Opens in $EDITOR

# Check service definitions
flox list -c

# View complete manifest
cat .flox/env/manifest.toml
```

## 📚 Links

- [Open WebUI Documentation](https://docs.openwebui.com/)
- [Open WebUI GitHub](https://github.com/open-webui/open-webui)
- [Ollama Documentation](https://ollama.ai/)
- [Ollama Model Library](https://ollama.ai/library)
- [Flox Documentation](https://flox.dev/docs)
- [NVIDIA CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)

## 📝 License

This Flox environment configuration is open source. Open WebUI and Ollama have their own respective licenses.