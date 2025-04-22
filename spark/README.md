# 🔥 A Flox Environment for Apache Spark Cluster Computing

The `spark` environment is designed for local, interactive use—especially when users need help configuring things step by step. It's designed both to be usable and to be a teaching tool for learning about Flox.

This environment simplifies Apache Spark cluster deployment by providing an interactive configuration wizard, automatic network detection, and service management.

The separate [`spark-basic`](https://github.com/barstoolbluz/floxenvs/blob/main/spark-basic/README.md) environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

## ✨ Features

- Interactive bootstrapping wizard for configuring either master or worker nodes;
- Automatic network IP detection and configuration;
- Automatic master-worker comms;
- Shell integration for common Spark commands;
- Flox service management for starting / stopping / restarting Spark;
- Cross-platform compatibility (Linux x86_64 and ARM64);
- Elegant, friendly terminal UI built with Gum.

## 🧰 Included Tools

The environment packs these essential tools:

- `spark` - Apache Spark distributed computing framework
- `jdk` - Java Development Kit, required to run Spark
- `gum` - Terminal UI toolkit powering the setup wizard
- `bat` - Better `cat` with syntax highlighting
- `curl` - HTTP client used for monitoring and diagnostics
- `pip` - Python package manager for extending Spark capabilities
- `gnused` - GNU implementation of the `sed` utility # provided for macOS compatibility
- `gawk` - GNU implementation of `awk` # provided for macOS compatibility
- `coreutils` - GNU core utilities # provided for macOS compatibility
- `gnugrep` GNU implementation of `grep` # provided for macOS compatibility

## 🏁 Getting Started

### 📋 Prerequisites

- Multi-node network or single machine for testing
- [Flox](https://flox.dev/get) installed on your system

### 💻 Installation & Activation

Jump in with:

1. Clone this repo

```sh
git clone https://github.com/yourusername/spark && cd spark
```

2. Run:

```sh
flox activate
```

This command:
- Pulls in all dependencies
- Fires up the Spark configuration wizard
- Sets up your environment as either a master or worker node
- Drops you into the Flox env with Spark ready to go

### 🧙 Configuration Wizard

First-time activation triggers a wizard that:

1. Lets you choose between master or worker node configuration;
2. Detects and configures network settings automatically;
3. Sets up proper IP address advertising for comms between Spark master and worker nodes;
4. Configures ports, memory, and CPU allocation;
5. Creates required directories for logs and data storage;

## 📝 Usage

After setup, you can manage your Spark cluster with simple commands:

```bash
# Start all Spark services
flox services start

# Check service status
flox services status

# Stop all services
flox services stop

# Reconfigure your Spark environment
reconfigure

# Run interactive Spark shell
spark-shell

# Run Python with Spark
pyspark

# Submit Spark applications
spark-submit your-application.jar
```

## 🔍 How It Works

### 🌐 Network Configuration

The environment implements a robust network configuration approach:

1. **Network Detection**:
   - Automatically identifies the machine's network IP
   - Allows manual override if needed

2. **Interface Binding**:
   - Master binds to all interfaces (0.0.0.0) for maximum connectivity
   - Workers use specific IP for proper connection to master

3. **Hostname Resolution**:
   - Uses IP addresses for communication instead of hostnames
   - Prevents common DNS/hostname resolution issues in distributed setups

### 🔧 Service Management

The environment leverages Flox's service management to:

1. Start and stop Spark services reliably
2. Monitor cluster status through intuitive terminal UI
3. Maintain proper environment variables across sessions

### 📊 Spark Integration

The environment configures Spark to:

- Use the correct network settings for distributed computing
- Allocate specified resources for workers (cores, memory)
- Maintain persistent data and log directories
- Provide easy access to all Spark commands and utilities

## 🔧 Troubleshooting

If Spark cluster communication breaks:

1. **Workers can't connect to master**:
   - Verify network connectivity between nodes
   - Check that the master's advertised IP is reachable from workers
   - Run `reconfigure` to reconfigure with correct network settings

2. **Service startup issues**:
   - Check logs in `$FLOX_ENV_CACHE/spark-logs/`
   - Ensure no port conflicts with existing services

3. **Performance issues**:
   - Adjust worker memory and cores via `reconfigure`
   - Check system resources and JVM settings

## 💻 System Compatibility

This works on:
- Linux (ARM64, x86_64)

## 📚 Additional Resources

- [Apache Spark Documentation](https://spark.apache.org/documentation.html)
- [Spark Programming Guide](https://spark.apache.org/docs/latest/programming-guide.html)
- [Spark Configuration](https://spark.apache.org/docs/latest/configuration.html)
- [Spark Cluster Mode Overview](https://spark.apache.org/docs/latest/cluster-overview.html)

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Content-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT
