# 🔥 A Flox Environment for Apache Kafka Event Streaming

The `kafka` environment is designed for local, interactive use—especially when users need help configuring things step by step. It's designed both to be usable and to be a teaching tool for learning about Kafka.

This environment simplifies Apache Kafka deployment by providing an interactive configuration wizard, automatic network detection, and service management using the KRaft protocol, which eliminates the need for Apache ZooKeeper.

## ✨ Features

- Interactive bootstrapping wizard for configuring various node types:
  - `kraft-combined` - Combined broker and controller (for simple setups)
  - `kraft-controller` - Metadata controller node (for advanced setups)
  - `kraft-broker` - Event broker node (for advanced setups)
  - `client` - Kafka producer/consumer client
- Automatic network IP detection and configuration
- Cluster ID management and synchronization across nodes
- Shell integration for common Kafka commands
- Flox service management for starting / stopping / restarting Kafka
- Cross-platform compatibility (Linux x86_64 and ARM64, macOS x86_64 and ARM64)
- Elegant, friendly terminal UI built with Gum

## 🧰 Included Tools

The environment packs these essential tools:

- `kafka` - Apache Kafka event streaming platform
- `jdk` - Java Development Kit, required to run Kafka
- `gum` - Terminal UI toolkit powering the setup wizard
- `jq` - JSON processor for data manipulation
- `curl` - HTTP client used for monitoring and diagnostics
- `netcat` - Network utility for connectivity checking
- `netstat` - Network statistics utility

## 🏁 Getting Started

### 📋 Prerequisites

- Multi-node network or single machine for testing
- [Flox](https://flox.dev/get) installed on your system

### 💻 Installation & Activation

Jump in with:

1. Clone this repo

```sh
git clone https://github.com/yourusername/kafka && cd kafka
```

2. Run:

```sh
flox activate -s
```

This command:
- Pulls in all dependencies
- Fires up the Kafka configuration wizard
- Sets up your environment as one of the node types
- Drops you into the Flox env with Kafka ready to go

### 🧙 Configuration Wizard

First-time activation triggers a wizard that:

1. Lets you choose between different node types:
   - `kraft-combined` - For simple setups (recommended for beginners)
   - `kraft-controller` - For advanced multi-node clusters
   - `kraft-broker` - For advanced multi-node clusters
   - `client` - For producing/consuming events
2. Detects and configures network settings automatically
3. Sets up proper IP address advertising for communication between nodes
4. Configures ports, replication factors, and partition settings
5. Creates required directories for logs and data storage
6. Generates and manages cluster IDs

### 📚 Understanding Kafka Node Types

When setting up a Kafka environment, you'll need to choose between different node types:

#### KRaft-Combined Mode
- **What it is**: A single node acting as both a controller (managing metadata) and a broker (handling data).
- **When to use it**: Perfect for development, testing, or small deployments.
- **Typical quantity**: 1 node for development; 3+ nodes for simple production clusters.

#### KRaft-Controller Mode
- **What it is**: A dedicated node that manages the cluster metadata and coordinates operations.
- **When to use it**: For large production deployments where you want to separate concerns.
- **Typical quantity**: 3 or 5 controllers for fault tolerance (odd number recommended).

#### KRaft-Broker Mode
- **What it is**: A dedicated node that handles the actual data streams and client connections.
- **When to use it**: For large production deployments with heavy workloads.
- **Typical quantity**: 3+ brokers, scaling as needed based on throughput requirements.

#### Client Mode
- **What it is**: A lightweight configuration for applications that only need to produce or consume data.
- **When to use it**: For applications, monitoring tools, or integration testing.
- **Typical quantity**: As many as needed for your applications.

### 🧱 Hard-coded Configuration

To skip the wizard, create `kafka_config.sh` in `$FLOX_ENV_CACHE`.

A `kafka_config.sh` file for a KRaft Combined node might look like this:

```
# Kafka config generated by Flox environment
KAFKA_MODE="kraft-combined"
KAFKA_CONFIG_DIR="$FLOX_ENV_CACHE/kafka-config"
KAFKA_LOG_DIR="$FLOX_ENV_CACHE/kafka-logs"
KAFKA_DATA_DIR="$FLOX_ENV_CACHE/data/kafka/kraft-combined-1"
KAFKA_NODE_ID="1"
KAFKA_HOST="192.168.0.88"
KAFKA_PORT="9092"
KRAFT_CONTROLLER_PORT="9093"
PROCESS_ROLES="broker,controller"
KAFKA_CLUSTER_ID="abcdefg123456"
```

A `kafka_config.sh` file for a KRaft Controller node might look like this:

```
# Kafka config generated by Flox environment
KAFKA_MODE="kraft-controller"
KAFKA_CONFIG_DIR="$FLOX_ENV_CACHE/kafka-config"
KAFKA_LOG_DIR="$FLOX_ENV_CACHE/kafka-logs"
KAFKA_DATA_DIR="$FLOX_ENV_CACHE/data/kafka/kraft-controller-1"
KAFKA_NODE_ID="1"
KAFKA_HOST="192.168.0.88"
KAFKA_PORT=""
KRAFT_CONTROLLER_PORT="9093"
PROCESS_ROLES="controller"
CONTROLLER_QUORUM="1@192.168.0.88:9093"
KAFKA_CLUSTER_ID="abcdefg123456"
```

A `kafka_config.sh` file for a KRaft Broker node might look like this:

```
# Kafka config generated by Flox environment
KAFKA_MODE="kraft-broker"
KAFKA_CONFIG_DIR="$FLOX_ENV_CACHE/kafka-config"
KAFKA_LOG_DIR="$FLOX_ENV_CACHE/kafka-logs"
KAFKA_DATA_DIR="$FLOX_ENV_CACHE/data/kafka/kraft-broker-2"
KAFKA_NODE_ID="2"
KAFKA_HOST="192.168.0.130"
KAFKA_PORT="9092"
KRAFT_CONTROLLER_PORT="9093"
PROCESS_ROLES="broker"
CONTROLLER_QUORUM="1@192.168.0.88:9093"
CONTROLLER_HOST="192.168.0.88"
CONTROLLER_PORT="9093"
CONTROLLER_NODE_ID="1"
KAFKA_CLUSTER_ID="abcdefg123456"
```

A `kafka_config.sh` file for a Kafka Client might look like this:

```
# Kafka config generated by Flox environment
KAFKA_MODE="client"
KAFKA_CONFIG_DIR="$FLOX_ENV_CACHE/kafka-config"
KAFKA_LOG_DIR="$FLOX_ENV_CACHE/kafka-logs"
KAFKA_DATA_DIR="$FLOX_ENV_CACHE/data/kafka"
BOOTSTRAP_SERVERS="192.168.0.88:9092"
CLIENT_TYPE="consumer"
KAFKA_TOPICS="my-topic"
KAFKA_CLIENT_COUNT="1"
KAFKA_CLIENT_PARALLEL="false"
KAFKA_MESSAGE_PROCESSING_MODE="echo"
KAFKA_MESSAGE_OUTPUT_DIR="$FLOX_ENV_CACHE/kafka-message-output"
KAFKA_SCRIPTS_DIR="$FLOX_ENV_CACHE/kafka-scripts"
KAFKA_FILE_APPEND="true"
```

## 📝 Usage

After setup, you can manage your Kafka cluster with simple commands:

```bash
# Start all Kafka services
flox services start

# Check service status
flox services status

# Stop all services
flox services stop

# Reconfigure your Kafka environment
bootstrap

# Create a Kafka topic
kreate my-topic 3 2  # Creates 'my-topic' with 3 partitions and replication factor 2

# List available topics
list

# Describe a specific topic
describe my-topic

# Check broker status
status
```

### 🚀 Custom Runtime Configuration

You can pass custom environment variables at runtime to tune your Kafka deployment:

```bash
# Basic activation with custom settings
KAFKA_DEFAULT_PARTITIONS="3" \
KAFKA_DEFAULT_REPLICATION="2" \
flox activate -s

# Advanced JVM and performance tuning
KAFKA_HEAP_OPTS="-Xms512m -Xmx1g" \
KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35" \
KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false" \
flox activate -s

# Advanced broker settings
KAFKA_NUM_NETWORK_THREADS="5" \
KAFKA_NUM_IO_THREADS="8" \
KAFKA_NUM_REPLICA_FETCHERS="2" \
KAFKA_MESSAGE_MAX_BYTES="1048576" \
KAFKA_AUTO_CREATE_TOPICS="true" \
KAFKA_LOG_RETENTION_HOURS="72" \
flox activate -s

# Comprehensive configuration example
KAFKA_DEFAULT_PARTITIONS="3" \
KAFKA_DEFAULT_REPLICATION="2" \
KAFKA_HEAP_OPTS="-Xms512m -Xmx1g" \
KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35" \
KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false" \
KAFKA_NUM_NETWORK_THREADS="5" \
KAFKA_NUM_IO_THREADS="8" \
KAFKA_NUM_REPLICA_FETCHERS="2" \
KAFKA_MESSAGE_MAX_BYTES="1048576" \
KAFKA_AUTO_CREATE_TOPICS="true" \
KAFKA_LOG_RETENTION_HOURS="72" \
flox activate -s
```

## 🔍 How It Works

### 🌐 Network Configuration

The environment implements a robust network configuration approach:

1. **Network Detection**:
   - Automatically identifies the machine's network IP
   - Allows manual override if needed

2. **Interface Binding**:
   - Controllers advertise their specific IP for proper cluster coordination
   - Brokers use specific IP for proper connection to controllers

3. **Hostname Resolution**:
   - Uses IP addresses for communication instead of hostnames
   - Prevents common DNS/hostname resolution issues in distributed setups

### 🔑 KRaft Protocol

The environment utilizes Kafka's KRaft protocol, which:

1. Eliminates the Zookeeper dependency
2. Simplifies the deployment architecture
3. Improves performance and scalability
4. Enhances security posture

### 🔧 Service Management

The environment leverages Flox's service management to:

1. Start and stop Kafka services reliably
2. Monitor cluster status through intuitive terminal UI
3. Maintain proper environment variables across sessions

### 📊 Kafka Integration

The environment configures Kafka to:

- Use the correct network settings for distributed computing
- Configure proper replication and partitioning for reliability
- Maintain persistent data and log directories
- Provide easy access to all Kafka commands and utilities

## 🔧 Troubleshooting

If Kafka cluster communication breaks:

1. **Brokers can't connect to controllers**:
   - Verify network connectivity between nodes
   - Check that the controller's advertised IP is reachable from brokers
   - Run `bootstrap` to reconfigure with correct network settings

2. **Service startup issues**:
   - Check logs in `$FLOX_ENV_CACHE/kafka-logs/`
   - Ensure no port conflicts with existing services
   - Verify the cluster ID matches across all nodes

3. **Performance issues**:
   - Adjust JVM memory settings via environment variables
   - Configure network and I/O thread counts
   - Check system resources and disk space

## 💻 System Compatibility

This works on:
- Linux (ARM64, x86_64)
- macOS (ARM64, x86_64)

## 📚 Additional Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kafka: The Definitive Guide](https://www.confluent.io/resources/kafka-the-definitive-guide/)
- [KRaft: Kafka without Zookeeper](https://developer.confluent.io/learn/kraft/)
- [Kafka Operations](https://kafka.apache.org/documentation/#operations)

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Path- and input-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT
