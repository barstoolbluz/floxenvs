# 🔥 Flox Environment for Apache Spark Cluster Computing

This `spark-basic` environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

The [`spark`](https://github.com/barstoolbluz/floxenvs/tree/main/spark/) environment is better for local, interactive use—especially when users need help configuring things step by step.

## ✨ Features

- Dynamic environment variable configuration for both master and worker nodes;
- Intelligent handling of pre-set environment variables;
- Automatic network IP detection with manual override capabilities;
- Separation of binding and advertising IPs for complex network environments;
- Cross-platform compatibility (Linux x86_64 and ARM64, macOS, Windows with WSL2);
- Flox service management for Spark resources;
- Default configurations that "just work" with minimal setup.

## 🧰 Included Tools

The environment includes these essential tools:

- `spark` - Apache Spark distributed computing framework
- `jdk` - Java Development Kit, required to run Spark
- `bat` - Better `cat` for viewing this `README.md`
- `curl` - HTTP client for downloading this `README.md` + other uses
- `pip` - Python v3.12.x and `pip` package manager for `pyspark` support
- `gnused` - GNU implementation of the `sed` editor # included for macOS compatibility
- `gawk` - GNU implementation of `awk` # idem
- `coreutils` - GNU `coreutils` # idem

## 🏁 Getting Started

### 📋 Prerequisites

- Network with at least two machines (or single machine for testing)
- [Flox](https://flox.dev/get) installed on your system

### 💻 Installation & Activation

Get started with:

```sh
# Clone the repo
git clone https://github.com/barstoolbluz/floxenvs && cd floxenvs/spark-basic

# Activate the environment
flox activate -s # uses hard-coded defaults; see below for injecting env vars and actiating
```

## 📝 Usage Scenarios

### Setting Up a Spark Master

To configure a machine as a Spark master node:

```bash
# Set master configuration
export SPARK_MODE="master"
export SPARK_LOCAL_IP="192.168.0.130"  # Your master's IP address
export SPARK_ADVERTISE_IP="192.168.0.130"  # IP to advertise to workers
export SPARK_PORT="7077"  # Master port
export SPARK_WEBUI_PORT="8080"  # Web UI port

# Activate the environment
flox activate -s

# Activate as a one-liner
SPARK_MODE=master SPARK_LOCAL_IP=192.168.0.130 SPARK_ADVERTISE_IP=192.168.0.130 SPARK_PORT=7077 SPARK_WEBUI_PORT=8080 flox activate -s
```

### Setting Up a Spark Worker

To configure a machine as a Spark worker node:

```bash
# Set worker configuration
export SPARK_MODE="worker"
export SPARK_HOST="192.168.0.130"  # IP of the master node
export SPARK_PORT="7077"  # Master port
export SPARK_MASTER_URL="spark://192.168.0.130:7077"  # Full master URL
export SPARK_LOCAL_IP="localhost"  # This worker's IP
export SPARK_WORKER_CORES="2"  # Number of cores to use
export SPARK_WORKER_MEMORY="2g"  # Amount of memory
export SPARK_WEBUI_PORT="8080"  # Worker Web UI port

# Activate the environment
flox activate -s

# Activate as a one-liner
SPARK_MODE=worker SPARK_HOST=192.168.0.130 SPARK_PORT=7077 SPARK_MASTER_URL=spark://192.168.0.130:7077 SPARK_LOCAL_IP=localhost SPARK_WORKER_CORES=2 SPARK_WORKER_MEMORY=2g SPARK_WEBUI_PORT=8080 flox activate -s
```

### Managing Your Spark Cluster

```bash
# Start all Spark services
flox services start

# Check service status
flox services status

# View service logs
flox services logs spark

# Stop all services
flox services stop

# Run interactive Spark shell
spark-shell

# Run Python with Spark
pyspark

# Submit Spark applications
spark-submit your-application.jar
```

## 🔍 How It Works

### 🌐 Network Configuration

1. **Flexible IP Handling**:
   - Respects pre-set environment variables
   - Falls back to automatic detection when not specified
   - Separates binding IPs from advertised IPs for complex setups

2. **Dynamic Configuration**:
   - Environment variables can be set before activation
   - No need to modify configuration files

3. **Service Integration**:
   - Spark runtime is managed by Flox's service manager
   - Proper log capture and reporting
   - Automatic startup of the correct service based on mode -- i.e., master or worker

### 🔧 Environment Variable Handling

This environment accepts pre-set environment variables:

- Spark-specific variables (e.g., `SPARK_MODE`, `SPARK_HOST`) set before activation take precedence over defaults
- Defaults are only applied when variables aren't already defined
- This enables flexible deployment across different network setups

## 🔧 Troubleshooting

If you encounter issues with your Spark cluster:

1. **Workers can't connect to master**:
   - Verify network connectivity between nodes
   - Ensure master's advertised IP is accessible from workers
   - Check firewall settings for ports 7077 and 8080

2. **Service startup issues**:
   - View logs with `flox services logs spark`
   - Look for detailed errors in `$SPARK_LOG_DIR`
   - Verify IP addresses are correct and nodes can reach each other

3. **Configuration problems**:
   - Use `env | grep SPARK` to view current settings
   - Modify environment variables before activation

## 💻 System Compatibility

This environment works on:
- Linux (ARM64, x86_64)
- macOS (ARM64, x86_64)

## 📚 Additional Resources

- [Apache Spark Documentation](https://spark.apache.org/documentation.html)
- [Spark Programming Guide](https://spark.apache.org/docs/latest/programming-guide.html)
- [Spark Configuration](https://spark.apache.org/docs/latest/configuration.html)
- [Spark Cluster Mode Overview](https://spark.apache.org/docs/latest/cluster-overview.html)

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Input- and path-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT
