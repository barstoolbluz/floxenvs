# 📓 A Flox Environment for JupyterLab

The `jupyterlab` environment is designed for local, interactive use—especially when users need help configuring things step by step. It provides a complete data science and notebook environment with an interactive setup wizard.

This environment simplifies JupyterLab deployment by providing an interactive configuration wizard, automatic virtual environment management, and service management through Flox.

## ✨ Features

- Interactive bootstrapping wizard for configuring JupyterLab settings:
  - Network host and port configuration
  - Authentication token setup
  - Notebook directory selection
  - Automatic package installation preferences
- Automatic Python virtual environment management
- Persistent configuration across sessions
- Automatic requirements.txt installation
- Shell integration with helper commands
- Flox service management for starting / stopping / restarting JupyterLab
- Cross-platform compatibility (Linux x86_64 and ARM64, macOS x86_64 and ARM64)
- Elegant, friendly terminal UI built with Gum

## 🧰 Included Tools

The environment packs these essential data science tools:

- `jupyterlab` - Modern web-based interactive development environment
- `jupyterlab-lsp` - Language Server Protocol integration
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
- `gum` - Terminal UI toolkit powering the setup wizard

## 🏁 Getting Started

### 📋 Prerequisites

- [Flox](https://flox.dev/get) installed on your system
- That's it.

### 💻 Installation & Activation

Jump in with:

1. Clone this repo

```sh
git clone https://github.com/yourusername/jupyterlab && cd jupyterlab
```

2. Run:

```sh
flox activate -s
```

This command:
- Pulls in all dependencies
- Fires up the JupyterLab configuration wizard
- Creates and activates a Python virtual environment
- Installs packages from requirements.txt (if present and enabled)
- Drops you into the Flox env with JupyterLab ready to go

### 🧙 Configuration Wizard

First-time activation triggers a wizard that:

1. Asks if you want to customize settings (or use defaults)
2. Lets you configure:
   - **Network**: Host address (0.0.0.0 for network access, 127.0.0.1 for local only)
   - **Port**: Default 8888, customize if needed
   - **Authentication**: Access token for security
   - **Notebook Directory**: Where to store your notebooks
   - **Package Management**: Auto-install from requirements.txt on activation
3. Saves your configuration for future activations
4. Makes helper functions available for managing your environment

### 🔄 Reconfiguration

Need to change your settings? Just run:

```bash
jupyter-reconfigure
```

Then deactivate and reactivate to run through the wizard again.

## 📝 Usage

After setup, you can manage your JupyterLab environment with these commands:

```bash
# Start JupyterLab service
flox activate -s

# Check service status
flox services status

# View service logs
flox services logs jupyter-lab

# Stop service (exit the environment)
exit

# Show detailed help information
jupyter-help

# Reconfigure JupyterLab settings
jupyter-reconfigure
```

### 🌐 Accessing JupyterLab

After starting the service, access JupyterLab in your browser:

1. Navigate to the URL shown on activation (default: `http://localhost:8888`)
2. Enter the access token when prompted (shown on activation)
3. Start creating notebooks!

### 📦 Python Package Management

The environment includes a dedicated virtual environment for your Python packages:

```bash
# Install packages
pip install scikit-learn tensorflow

# Create a requirements.txt for reproducibility
pip freeze > requirements.txt

# Packages in requirements.txt are automatically installed on activation
# (if INSTALL_REQUIREMENTS=true, which is the default)
```

### 🗂️ Notebook Organization

By default, notebooks are stored in the environment directory. You can:

- Change the notebook directory via the configuration wizard
- Organize notebooks in subdirectories
- Use version control (git) to track notebook changes

## 🔍 How It Works

### 🌐 Network Configuration

The environment supports two network modes:

1. **Network Access (0.0.0.0)**:
   - JupyterLab accessible from other devices on your network
   - Useful for remote work or accessing from mobile devices
   - Access via `http://<your-ip>:8888`

2. **Local Only (127.0.0.1)**:
   - JupyterLab only accessible from this computer
   - More secure for sensitive work
   - Access via `http://localhost:8888`

### 🔐 Authentication

The environment uses token-based authentication:

- Token is set during initial configuration
- Token is required for browser access
- Token is displayed on every activation
- Change token anytime via `jupyter-reconfigure`

### 🐍 Virtual Environment Management

The environment automatically:

1. Creates a Python virtual environment in `$FLOX_ENV_CACHE/venv`
2. Activates the venv on every environment activation
3. Installs packages from `requirements.txt` (if enabled)
4. Makes all installed packages available in JupyterLab

### 💾 Configuration Persistence

Your settings are saved in `$FLOX_ENV_CACHE/jupyter_config.sh`:

- Configuration persists across sessions
- Settings survive environment updates
- Helper functions saved for shell integration
- Easy to back up or share (except tokens!)

## 🔧 Troubleshooting

If JupyterLab has issues:

1. **Service won't start**:
   - Check logs: `flox services logs jupyter-lab`
   - Verify port isn't in use: `netstat -an | grep 8888`
   - Check virtual environment: `echo $VENV_DIR`

2. **Can't access in browser**:
   - Verify service is running: `flox services status`
   - Check the URL and token shown on activation
   - For network access, ensure firewall allows connections
   - Try using the IP address instead of localhost

3. **Package installation fails**:
   - Activate environment and run: `pip install <package>` manually
   - Check requirements.txt for syntax errors
   - Ensure internet connection for package downloads

4. **Need to start fresh**:
   - Run `jupyter-reconfigure` to reset configuration
   - Or manually delete: `rm -rf $FLOX_ENV_CACHE/jupyter_config.sh $FLOX_ENV_CACHE/venv`

## 💻 System Compatibility

This works on:
- Linux (ARM64, x86_64)
- macOS (ARM64, x86_64)

## 📚 Additional Resources

- [JupyterLab Documentation](https://jupyterlab.readthedocs.io/)
- [Jupyter Notebook Tutorial](https://jupyter-notebook.readthedocs.io/en/stable/)
- [Python Data Science Handbook](https://jakevdp.github.io/PythonDataScienceHandbook/)
- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [Matplotlib Gallery](https://matplotlib.org/stable/gallery/index.html)

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Path- and input-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT
