# ComfyUI Flox Environment

Production-ready ComfyUI environment with optimized workflows and smart defaults.

## Quick Start

```bash
# Activate the environment
cd /home/daedalus/dev/floxenvs/comfyui
flox activate

# Download models (in activated environment)
comfyui-download sd15    # Stable Diffusion 1.5
comfyui-download sdxl    # Stable Diffusion XL
comfyui-download sd35    # Stable Diffusion 3.5 (requires HF token)
comfyui-download flux    # FLUX.1 Dev (requires HF token)

# Start ComfyUI
flox services start comfyui

# Or manually with custom options
comfyui --listen 0.0.0.0 --port 8188
```

## Features

✅ **Auto-configured paths** - Models, outputs, inputs automatically organized
✅ **Model downloads** - Interactive scripts with smart token handling
✅ **FLUX optimization** - nunchaku for faster inference
✅ **Advanced ControlNet** - controlnet-aux preprocessors
✅ **Custom node dependencies** - comfyui-extras package provides common dependencies
✅ **Helper aliases** - Quick commands for common tasks

## Directory Structure

```
~/comfyui-work/
├── models/
│   ├── checkpoints/     # SD checkpoints
│   ├── clip/            # CLIP & text encoders
│   ├── unet/            # FLUX UNet models
│   ├── vae/             # VAE models
│   ├── loras/           # LoRA weights
│   ├── upscale_models/  # Upscaler models
│   ├── controlnet/      # ControlNet models
│   └── embeddings/      # Textual inversions
├── output/              # Generated images
├── input/               # Input images
├── temp/                # Temporary files
├── custom_nodes/        # Custom nodes (install manually)
└── default/
    └── workflows/       # Saved workflows (appear in web UI)
```

## Environment Variables

Set in `.flox/env/manifest.toml`:

- `COMFYUI_WORK_DIR` - Base directory (`~/comfyui-work`)
- `COMFYUI_MODELS_DIR` - Models location
- `COMFYUI_OUTPUT_DIR` - Output location
- `COMFYUI_INPUT_DIR` - Input location
- `COMFYUI_TEMP_DIR` - Temp location
- `COMFYUI_DATABASE_URL` - SQLite database location (in Flox cache)
- `COMFYUI_LISTEN` - Server listen address (`0.0.0.0`)
- `COMFYUI_PORT` - Server port (`8188`)

## Helper Commands

When environment is activated:

- `flox services start comfyui` - Start ComfyUI service (auto-detects CUDA/MPS/CPU)
- `flox services logs comfyui` - View service logs
- `comfyui-download` - Download AI models
- `cdwork` - cd to ~/comfyui-work
- `cdmodels` - cd to models directory
- `cdoutput` - cd to output directory

## GPU Acceleration

**Default:** CPU mode (generic PyTorch)

The environment automatically detects available compute backends:
- **CUDA** (NVIDIA GPUs on Linux)
- **Metal/MPS** (Apple Silicon on macOS)
- **CPU** (fallback)

### macOS with Apple Silicon

PyTorch from nixpkgs includes MPS support by default - no additional setup needed!

### Linux with NVIDIA GPU (CUDA)

The manifest includes **commented-out CUDA-accelerated packages** from the `flox-cuda` catalog. To enable GPU acceleration:

```bash
flox edit
```

**Uncomment these packages in the `[install]` section:**

1. **PyTorch with CUDA** (lines 15-28):
   ```toml
   torch-cuda.pkg-path = "flox-cuda/python3Packages.torch"
   torch-cuda.systems = ["x86_64-linux", "aarch64-linux"]
   torch-cuda.priority = 1
   torch-cuda.pkg-group = "torch-cuda"

   torchvision-cuda.pkg-path = "flox-cuda/python3Packages.torchvision"
   torchvision-cuda.systems = ["x86_64-linux", "aarch64-linux"]
   torchvision-cuda.priority = 2
   torchvision-cuda.pkg-group = "torchvision-cuda"

   torchaudio-cuda.pkg-path = "flox-cuda/python3Packages.torchaudio"
   torchaudio-cuda.systems = ["x86_64-linux", "aarch64-linux"]
   torchaudio-cuda.priority = 3
   torchaudio-cuda.pkg-group = "torchvision-cuda"
   ```

2. **CUDA-accelerated Python libraries** (lines 36-51) - Optional but recommended:
   ```toml
   numpy.pkg-path = "flox-cuda/python3Packages.numpy"
   numpy.systems = ["x86_64-linux"]
   numpy.priority = 3

   scipy.pkg-path = "flox-cuda/python3Packages.scipy"
   scipy.systems = ["x86_64-linux"]
   scipy.priority = 4

   scikit-image.pkg-path = "flox-cuda/python3Packages.scikit-image"
   scikit-image.systems = ["aarch64-linux", "x86_64-linux"]
   scikit-image.priority = 1

   opencv4.pkg-path = "flox-cuda/python3Packages.opencv4"
   opencv4.systems = ["x86_64-linux", "aarch64-linux"]
   opencv4.priority = 2
   ```

**After uncommenting:**
```bash
flox activate  # or restart the environment
flox services restart comfyui
```

The service will automatically detect and use CUDA acceleration.

**Build your own:** The manifest references custom CUDA builds at:
- https://github.com/barstoolbluz/build-pytorch
- https://github.com/barstoolbluz/build-torchvision
- https://github.com/barstoolbluz/build-torchaudio

## Custom Nodes

Install custom nodes in `~/comfyui-work/custom_nodes/`:

```bash
cd ~/comfyui-work/custom_nodes

# Example: Install GGUF support
git clone https://github.com/city96/ComfyUI-GGUF

# Example: Install rgthree utilities
git clone https://github.com/rgthree/rgthree-comfy
```

See the build repository's `USAGE.md` for recommended custom nodes.

## Custom Node Dependencies (comfyui-extras)

This environment includes the **comfyui-extras** package, which provides common Python dependencies required by popular custom nodes:

**Included packages:**
- piexif, simpleeval, numba, gitpython, onnxruntime, fairscale, easydict, pymatting, pillow-heif
- colour-science, clip-interrogator, img2texture, cstr, ffmpy, color-matcher, rembg
- pixeloe, transparent-background (platform-dependent)
- albumentations (Linux only)

**Supported custom nodes:**
- ✅ ComfyUI-Image-Saver (piexif)
- ✅ was-node-suite-comfyui (all WASasquatch packages)
- ✅ ComfyUI_essentials (numba, colour-science, rembg, etc.)
- ✅ ComfyUI-KJNodes (color-matcher)
- ✅ efficiency-nodes-comfyui (clip-interrogator, simpleeval)

**Platform notes:**
- **Linux**: All 19 packages (17 on aarch64 - excludes pixeloe, transparent-background)
- **macOS**: 18 packages (excludes albumentations due to compilation issues)

With comfyui-extras installed, most custom nodes will work out-of-the-box without needing `pip install --break-system-packages`.

**To disable comfyui-extras:**
If you don't need these dependencies, you can comment out the package in the manifest:
```bash
flox edit
# Comment out lines 10-12 in [install] section:
# comfyui-extras.pkg-path = "flox/comfyui-extras"
# comfyui-extras.priority = 2
# comfyui-extras.pkg-group = "comfyui-extras"
```

## Running as a Service

The service is **enabled by default** and automatically detects your compute backend:
- 🚀 **CUDA** (NVIDIA GPUs) - Runs with GPU acceleration
- 🍎 **Metal/MPS** (Apple Silicon) - Runs with Apple Silicon acceleration
- 💻 **CPU** - Falls back to CPU mode if no GPU detected

Start the service:

```bash
# Option 1: Start with activation
flox activate --start-services

# Option 2: Start in already-activated environment
flox services start comfyui

# View logs
flox services logs comfyui
```

The service automatically adds `--cpu` flag when no GPU is available, ensuring it works correctly in all environments.

## Updating the Package

When a new ComfyUI version is published:

```bash
# Force upgrade...
flox upgrade

# ...and/or edit 'manifest.toml' to define the new version: e.g., 'comfyui.version = "0.3.76"'
flox edit

# Then restart the environment
flox activate -s
```

## Troubleshooting

### Models not found
The `extra_model_paths.yaml` file is auto-generated in `$FLOX_ENV_CACHE` on activation. If models aren't loading, check that `~/comfyui-work/models/` directories exist and contain models.

### CUDA not working

**Check if PyTorch has CUDA support:**
```bash
python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA built: {torch.version.cuda}')"
```

If it shows `CUDA available: False` or `CUDA built: None`, your PyTorch package **was not built with CUDA support**.

**To fix:**
1. Verify your GPU is detected: `nvidia-smi`
2. Check your PyTorch package was built with CUDA:
   - If building custom packages, ensure CUDA is enabled in the build
   - Try nixpkgs CUDA version: `python313Packages.pytorchWithCuda`
3. Rebuild and republish your PyTorch package with CUDA enabled

**Common issue:** Package name contains "cuda" but wasn't actually built with CUDA support. Always verify with the python commands above.

### Custom node errors

Most custom node dependencies are provided by the **comfyui-extras** package. If a custom node still has missing dependencies:

```bash
cd ~/comfyui-work/custom_nodes/YourNode
pip install -r requirements.txt --break-system-packages
```

Check the comfyui-extras documentation to see if the missing dependency can be added to the package.

## License

GPL-3.0 (ComfyUI upstream license)
