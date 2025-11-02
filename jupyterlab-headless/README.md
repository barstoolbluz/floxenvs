# 🚀 Flox Environment for JupyterLab

This `jupyterlab-headless` environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

## ✨ Features

- Dynamic environment variable configuration for JupyterLab settings
- Runtime override capabilities for all configuration options
- Automatic Python virtual environment management
- Support for automatic requirements.txt installation
- Cross-platform compatibility (Linux x86_64 and ARM64, macOS x86_64 and ARM64)
- Flox service management for JupyterLab
- Default configurations that "just work" with minimal setup
- Automatic token generation for secure access

## 🧰 Included Tools

The environment includes these essential data science tools:

- `jupyterlab` - Modern web-based interactive development environment
- `jupyterlab-lsp` - Language Server Protocol integration
- `jupyterlab-server` - JupyterLab server components
- `jupyterlab-widgets` - Interactive widgets for notebooks
- `jupyterlab-pygments` - Syntax highlighting
- `jupyterlab-execute-time` - Cell execution time display
- `pandas` - Data manipulation and analysis
- `matplotlib` - Data visualization
- `numpy` - Numerical computing
- `pyarrow` - Columnar data format support
- `sympy` - Symbolic mathematics
- `pydot` - Graph visualization
- `plotly` - Interactive plotting
- `figlet` - ASCII art for welcome messages
- `gum` - Terminal UI toolkit

## 🏁 Getting Started

### 📋 Prerequisites

- [Flox](https://flox.dev/get) installed on your system
- That's it.

### 💻 Installation & Activation

Get started with:

```sh
# Clone the repo
git clone https://github.com/barstoolbluz/floxenvs && cd floxenvs/jupyterlab-headless

# Activate the environment with defaults
flox activate -s
```

This will:
- Create a Python virtual environment
- Start JupyterLab on localhost:8888
- Generate a secure random token
- Display connection information

## 📝 Usage Scenarios

### Basic Activation with Defaults

Start JupyterLab with sensible defaults:

```bash
flox activate -s
```

Defaults:
- Host: `localhost`
- Port: `8888`
- Token: Auto-generated secure random string
- Notebook Directory: Current directory
- Requirements Installation: Disabled

### Custom Network Configuration

Configure JupyterLab for network access:

```bash
# Listen on all interfaces for remote access
JUPYTER_HOST="0.0.0.0" \
JUPYTER_PORT="8888" \
JUPYTER_SERVER_TOKEN="my-secret-token" \
flox activate -s
```

One-liner:
```bash
JUPYTER_HOST=0.0.0.0 JUPYTER_PORT=8888 JUPYTER_SERVER_TOKEN=my-secret-token flox activate -s
```

### Custom Notebook Directory

Specify where notebooks should be stored:

```bash
# Use a specific directory for notebooks
NOTEBOOK_DIR="/path/to/my/notebooks" \
flox activate -s
```

One-liner:
```bash
NOTEBOOK_DIR=/path/to/my/notebooks flox activate -s
```

### Automatic Requirements Installation

Enable automatic package installation from requirements.txt:

```bash
# Auto-install packages on activation
INSTALL_REQUIREMENTS="true" \
flox activate -s
```

One-liner:
```bash
INSTALL_REQUIREMENTS=true flox activate -s
```

### Custom Virtual Environment Location

Specify a custom location for the Python virtual environment:

```bash
# Use a specific directory for venv
VENV_DIR="/path/to/custom/venv" \
flox activate -s
```

One-liner:
```bash
VENV_DIR=/path/to/custom/venv flox activate -s
```

### Complete Custom Configuration

Combine multiple settings for full control:

```bash
# Full custom configuration
JUPYTER_HOST="0.0.0.0" \
JUPYTER_PORT="9999" \
JUPYTER_SERVER_TOKEN="super-secure-token-123" \
NOTEBOOK_DIR="/home/user/my-notebooks" \
VENV_DIR="/home/user/jupyter-venv" \
INSTALL_REQUIREMENTS="true" \
flox activate -s
```

One-liner:
```bash
JUPYTER_HOST=0.0.0.0 JUPYTER_PORT=9999 JUPYTER_SERVER_TOKEN=super-secure-token-123 NOTEBOOK_DIR=/home/user/my-notebooks VENV_DIR=/home/user/jupyter-venv INSTALL_REQUIREMENTS=true flox activate -s
```

### Using Flox Environment Composition

Flox v1.4+ supports environment composition, allowing you to create a customized environment that builds upon `jupyterlab-headless`. The env vars you define in `[vars]` override those hard-coded into `jupyterlab-headless`.

```toml
# manifest.toml for your composed environment
version = 1

[vars]
JUPYTER_HOST = "0.0.0.0"
JUPYTER_PORT = "8888"
JUPYTER_SERVER_TOKEN = "my-secure-token"
NOTEBOOK_DIR = "/home/user/notebooks"
INSTALL_REQUIREMENTS = "true"

[include]
environments = [
    { remote = "barstoolbluz/jupyterlab-headless" }
]

[options]
systems = [
  "aarch64-darwin",
  "aarch64-linux",
  "x86_64-darwin",
  "x86_64-linux",
]
```

This approach allows you to:
- Customize the JupyterLab configuration
- Reuse the `jupyterlab-headless` environment without modifying it
- Create different compositions for different deployment scenarios
- Version control your configuration without the base environment

### Managing JupyterLab Service

```bash
# Start JupyterLab service
flox services start

# Check service status
flox services status

# View service logs
flox services logs jupyter-lab

# Follow logs in real-time
flox services logs --follow jupyter-lab

# Stop service
flox services stop
```

## 🔍 Configuration Variables

All configuration is done via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `JUPYTER_HOST` | `localhost` | Host to bind JupyterLab server |
| `JUPYTER_PORT` | `8888` | Port for JupyterLab server |
| `JUPYTER_SERVER_TOKEN` | Auto-generated | Authentication token (use openssl to generate) |
| `NOTEBOOK_DIR` | Current directory | Directory for storing notebooks |
| `VENV_DIR` | `$FLOX_ENV_CACHE/venv` | Python virtual environment location |
| `INSTALL_REQUIREMENTS` | `false` | Auto-install from requirements.txt |

### Generating Secure Tokens

For production use, generate a secure token:

```bash
# Generate a random token
openssl rand -hex 32

# Use it with JupyterLab
JUPYTER_SERVER_TOKEN="$(openssl rand -hex 32)" flox activate -s
```

## 🔍 How It Works

### 🐍 Virtual Environment Management

1. **Automatic Creation**:
   - Creates venv at `$VENV_DIR` (default: `$FLOX_ENV_CACHE/venv`)
   - Activates on every environment activation
   - Isolated from system Python packages

2. **Requirements Installation**:
   - When `INSTALL_REQUIREMENTS=true` and `requirements.txt` exists
   - Automatically runs `pip install -r requirements.txt`
   - Only installs when file is present

3. **Service Integration**:
   - JupyterLab service activates the venv
   - All installed packages available in notebooks
   - Consistent environment between shell and notebook kernel

### 🌐 Network Modes

1. **Localhost Only** (`JUPYTER_HOST=localhost` or `127.0.0.1`):
   - Only accessible from the local machine
   - More secure for sensitive work
   - Access via: `http://localhost:8888`

2. **Network Access** (`JUPYTER_HOST=0.0.0.0`):
   - Accessible from any network interface
   - Useful for remote work or team collaboration
   - Access via: `http://<your-ip>:8888`
   - **Security**: Always use a strong token for network access

### 🔐 Security

- Token-based authentication required for all access
- Auto-generated secure tokens if not provided
- Tokens displayed on activation for easy access
- Change token anytime via environment variable

### 📂 Directory Structure

The environment organizes data in consistent locations:

- `$VENV_DIR` - Python virtual environment (default: `$FLOX_ENV_CACHE/venv`)
- `$NOTEBOOK_DIR` - Jupyter notebooks (default: current directory)
- `$FLOX_ENV_CACHE` - Flox environment cache

## 🔧 Troubleshooting

Common issues and solutions:

1. **Service Won't Start**:
   - Check if port is already in use: `netstat -an | grep 8888`
   - View logs: `flox services logs jupyter-lab`
   - Verify environment variables: `env | grep JUPYTER`

2. **Can't Access JupyterLab**:
   - Verify service is running: `flox services status`
   - Check firewall settings for network access
   - Ensure correct URL and token are used
   - Try `http://<ip>:8888` instead of hostname

3. **Package Installation Fails**:
   - Check requirements.txt syntax
   - Manually install: activate environment, then `pip install <package>`
   - Verify internet connectivity
   - Check pip logs in venv directory

4. **Virtual Environment Issues**:
   - Delete and recreate: `rm -rf $VENV_DIR` then reactivate
   - Check `VENV_DIR` path is writable
   - Ensure Python 3.12 is available

5. **Token Issues**:
   - Check token in activation output
   - Regenerate: `JUPYTER_SERVER_TOKEN="$(openssl rand -hex 32)" flox activate -s`
   - Verify token matches what's shown on activation

## 🌐 Production Deployment Tips

For production or team use:

1. **Security**:
   - Always use strong, unique tokens
   - Consider HTTPS reverse proxy (nginx, Caddy)
   - Restrict network access via firewall rules
   - Regularly update packages: `pip install --upgrade jupyterlab`

2. **Performance**:
   - Increase memory for large datasets
   - Use SSD for notebook storage
   - Monitor resource usage
   - Consider dedicated venv per project

3. **Collaboration**:
   - Use version control (git) for notebooks
   - Share requirements.txt for reproducibility
   - Document custom configurations
   - Consider JupyterHub for multi-user scenarios

4. **Backup**:
   - Regularly backup `$NOTEBOOK_DIR`
   - Export notebooks to different formats (HTML, PDF)
   - Version control your requirements.txt
   - Document environment configurations

## 💻 System Compatibility

This environment works on:
- Linux (ARM64, x86_64)
- macOS (ARM64, x86_64)

## 📚 Additional Resources

- [JupyterLab Documentation](https://jupyterlab.readthedocs.io/)
- [Jupyter Server Documentation](https://jupyter-server.readthedocs.io/)
- [Python Virtual Environments](https://docs.python.org/3/library/venv.html)
- [Data Science with Python](https://jakevdp.github.io/PythonDataScienceHandbook/)
- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [Matplotlib Gallery](https://matplotlib.org/stable/gallery/index.html)

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Input- and path-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT
