# 🚀 Flox Environment for Apache Kafka Event Streaming

This `kafka` environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

## ✨ Features

- Dynamic environment variable configuration for KRaft mode (broker, controller, or combined)
- Intelligent auto-detection of network settings with manual override capabilities
- Hash-based configuration detection for automatic state reset when settings change
- Support for various client operations (producers and consumers)
- Cross-platform compatibility (Linux x86_64 and ARM64, macOS)
- Flox service management for Kafka resources
- Default configurations that "just work" with minimal setup

## 🧰 Included Tools

The environment includes these essential tools:

- `kafka` - Apache Kafka distributed streaming platform
- `jdk` - Java Development Kit, required to run Kafka
- `bat` - Better `cat` for viewing this `README.md`
- `curl` - HTTP client for downloading this `README.md` + other uses
- `jq` - JSON processor for supporting Kafka helper functions
- `gum` - Shell script toolkit for Kafka helper functions
- `gawk` - GNU implementation of `awk` # included for macOS/Darwin compatibility
- `coreutils` - GNU `coreutils` # idem
- `gnugrep` - GNU implementation of `grep` # idem

## 🏁 Getting Started

### 📋 Prerequisites

- [Flox](https://flox.dev/get) installed on your system
- That's it.

### 💻 Installation & Activation

Get started with:

```sh
# Clone the repo
git clone https://github.com/barstoolbluz/floxenvs && cd floxenvs/kafka

# Activate the environment
flox activate -s # uses hard-coded defaults (kraft-combined mode)
```

## 📝 Usage Scenarios

### Setting Up a KRaft Combined Node (Broker + Controller)

To configure a machine as a combined Kafka broker and controller:

```bash
# Set combined node configuration
KAFKA_MODE="kraft-combined" \
KAFKA_NODE_ID="1" \
KAFKA_HOST="localhost" \
KAFKA_PORT="9092" \
KRAFT_CONTROLLER_PORT="9093" \
KAFKA_CLUSTER_ID="EBzt0KoZR5ynZ9hTiJQuFA" \
KAFKA_REPLICATION_FACTOR="1" \
KAFKA_NUM_PARTITIONS="1" \
KAFKA_HEAP_OPTS="-Xmx512M -Xms512M" \
flox activate -s
```

One-liner:
```bash
KAFKA_MODE=kraft-combined KAFKA_NODE_ID=1 KAFKA_HOST=localhost KAFKA_PORT=9092 KRAFT_CONTROLLER_PORT=9093 KAFKA_REPLICATION_FACTOR=1 KAFKA_NUM_PARTITIONS=1 KAFKA_HEAP_OPTS="-Xmx512M -Xms512M" flox activate -s
```

### Setting Up a KRaft Controller-Only Node

To configure a machine as a Kafka controller node:

```bash
# Set controller configuration
KAFKA_MODE="kraft-controller" \
KAFKA_NODE_ID="1" \
KAFKA_HOST="localhost" \
KRAFT_CONTROLLER_PORT="9093" \
KAFKA_CLUSTER_ID="EBzt0KoZR5ynZ9hTiJQuFA" \
KAFKA_HEAP_OPTS="-Xmx512M -Xms512M" \
flox activate -s
```

One-liner:
```bash
KAFKA_MODE=kraft-controller KAFKA_NODE_ID=1 KAFKA_HOST=localhost KRAFT_CONTROLLER_PORT=9093 KAFKA_HEAP_OPTS="-Xmx512M -Xms512M" flox activate -s
```

### Setting Up a KRaft Broker-Only Node

To configure a machine as a Kafka broker node:

```bash
# Set broker configuration
KAFKA_MODE="kraft-broker" \
KAFKA_NODE_ID="2" \
KAFKA_HOST="localhost" \
KAFKA_PORT="9092" \
CONTROLLER_QUORUM="1@controller-host:9093" \
KAFKA_CLUSTER_ID="EBzt0KoZR5ynZ9hTiJQuFA" \
KAFKA_REPLICATION_FACTOR="1" \
KAFKA_NUM_PARTITIONS="1" \
KAFKA_HEAP_OPTS="-Xmx512M -Xms512M" \
flox activate -s
```

One-liner:
```bash
KAFKA_MODE=kraft-broker KAFKA_NODE_ID=2 KAFKA_HOST=localhost KAFKA_PORT=9092 CONTROLLER_QUORUM="1@controller-host:9093" KAFKA_CLUSTER_ID="EBzt0KoZR5ynZ9hTiJQuFA" KAFKA_REPLICATION_FACTOR=1 KAFKA_NUM_PARTITIONS=1 KAFKA_HEAP_OPTS="-Xmx512M -Xms512M" flox activate -s
```

### Setting Up a Kafka Producer Client

To configure a machine as a Kafka producer:

```bash
# Set producer configuration
KAFKA_MODE="client" \
CLIENT_TYPE="producer" \
BOOTSTRAP_SERVERS="localhost:9092" \
KAFKA_TOPICS="my-topic" \
KAFKA_CLIENT_COUNT="1" \
KAFKA_CLIENT_PARALLEL="false" \
KAFKA_MESSAGE_PROCESSING_MODE="echo" \
flox activate -s
```

One-liner:
```bash
KAFKA_MODE=client CLIENT_TYPE=producer BOOTSTRAP_SERVERS="localhost:9092" KAFKA_TOPICS="my-topic" KAFKA_CLIENT_COUNT=1 KAFKA_CLIENT_PARALLEL=false KAFKA_MESSAGE_PROCESSING_MODE=echo flox activate -s
```

### Setting Up a Kafka Consumer Client

To configure a machine as a Kafka consumer:

```bash
# Set consumer configuration
KAFKA_MODE="client" \
CLIENT_TYPE="consumer" \
BOOTSTRAP_SERVERS="localhost:9092" \
KAFKA_TOPICS="my-topic" \
KAFKA_CLIENT_COUNT="1" \
KAFKA_CLIENT_PARALLEL="false" \
KAFKA_MESSAGE_PROCESSING_MODE="echo" \
KAFKA_MESSAGE_OUTPUT_DIR="$HOME/kafka-output" \
flox activate -s
```

One-liner:
```bash
KAFKA_MODE=client CLIENT_TYPE=consumer BOOTSTRAP_SERVERS="localhost:9092" KAFKA_TOPICS="my-topic" KAFKA_CLIENT_COUNT=1 KAFKA_CLIENT_PARALLEL=false KAFKA_MESSAGE_PROCESSING_MODE=echo flox activate -s
```

### Using Flox Environment Composition

Flox v1.4+ supports environment composition, allowing you to create customized environments that build upon `kafka` and combine it with other services.

#### Compose with Karapace (Schema Registry + REST Proxy)

Create a complete Kafka stack with schema management. The first example uses local Flox manifests:

**kafka-stack/.flox/env/manifest.toml:**
```toml
version = 1

## When composing manifests that consume custom-built packages, it is sometimes
## necessary to redeclare packages with package groups in the composing
## manifest,even though they're already defined in the included environment.
## Without this, Flox's dependency resolver will fail. For example:
[install]
karapace.pkg-path = "flox/karapace"
karapace.pkg-group = "karapace"

[include]
environments = [
    { dir = "../kafka" },      # local kafka manifest
    { dir = "../karapace" }    # local karapace manifest
]

## In this case, the karapace manifest defines a custom-built package, along
## with a karapace-specific package-group. In spite of this, we redefine a
## package group override for karapace in the composing manifest.

```

The second example uses remote environments managed by FloxHub:

**Remote composition (FloxHub):**
```toml
# kafka-stack/.flox/env/manifest.toml
version = 1

[include]
environments = [
    { remote = "floxrox/kafka" },
    { remote = "floxrox/karapace" }
]
```
The third example uses both local and remote environments:

**Mixed (local + remote):**
```toml
version = 1

[include]
environments = [
    { remote = "floxrox/kafka" },                     # Use published Kafka
    { dir = "../karapace-custom", name = "karapace" } # Use local customized Karapace
]
```

Usage:
```bash
cd kafka-stack
flox activate -s

# Start Kafka first
flox services start kafka

# Then start Karapace services (auto-detect Kafka connection)
flox services start karapace-registry  # Schema Registry on port 8081
flox services start karapace-rest      # REST Proxy on port 8082

# Verify all services
flox services status
```

#### Customize Kafka Configuration

Override Kafka settings while using the published environment:

```toml
# my-kafka/.flox/env/manifest.toml
version = 1

[vars]
KAFKA_MODE = "kraft-broker"
KAFKA_NODE_ID = "2"
KAFKA_HOST = "localhost"
KAFKA_PORT = "9092"
CONTROLLER_QUORUM = "1@controller-host:9093"
KAFKA_CLUSTER_ID = "EBzt0KoZR5ynZ9hTiJQuFA"
KAFKA_REPLICATION_FACTOR = "1"
KAFKA_NUM_PARTITIONS = "1"
KAFKA_HEAP_OPTS = "-Xmx512M -Xms512M"

[include]
environments = [
    { remote = "floxrox/kafka" }
]
```

This composition approach allows you to:
- Combine Kafka with Schema Registry, monitoring tools, or clients
- Customize configuration without modifying base environments
- Use local environments during development, remote in production
- Create different compositions for different deployment scenarios
- Share complete stacks via FloxHub

### Managing Your Kafka Cluster

```bash
# Start Kafka service
flox services start

# Check service status
flox services status

# View service logs
flox services logs [--follow] kafka 	# the `--follow` option continuously prints log events to the console

# Stop service
flox services stop
```

## Kafka Command Reference

### Topic Management

```bash
# Create a topic
kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my-topic --partitions 1 --replication-factor 1

# List topics
kafka-topics.sh --bootstrap-server localhost:9092 --list

# Describe a topic
kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic my-topic

# Delete a topic
kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic my-topic
```

### Message Production and Consumption

```bash
# Produce messages (interactive)
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic my-topic

# Produce messages from a file
cat data.txt | kafka-console-producer.sh --bootstrap-server localhost:9092 --topic my-topic

# Consume messages
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic my-topic --from-beginning

# Consume messages with formatted output
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic my-topic --from-beginning --property print.key=true --property print.value=true --property key.separator=:
```

### Consumer Group Management

```bash
# List consumer groups
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

# Describe a consumer group
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group my-group

# Reset consumer group offsets
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group my-group --topic my-topic --reset-offsets --to-earliest --execute
```

### Performance Testing

```bash
# Producer performance test
kafka-producer-perf-test.sh --topic my-topic --num-records 1000000 --record-size 1000 --throughput 10000 --producer-props bootstrap.servers=localhost:9092

# Consumer performance test
kafka-consumer-perf-test.sh --bootstrap-server localhost:9092 --topic my-topic --messages 1000000
```

## 🔍 Architecture and KRaft Mode

Apache Kafka 4.0+ uses the KRaft (Kafka Raft) consensus protocol, which eliminates the dependency on ZooKeeper. This environment is configured to use KRaft mode, which offers several benefits:

- **Simplified Architecture**: No need for a separate ZooKeeper ensemble
- **Improved Performance**: Reduced client latency and better scalability
- **Easier Operations**: Single system to monitor and maintain

### KRaft Deployment Models

This environment supports three KRaft deployment modes:

1. **Combined Mode (Default)**: Controller and broker roles on the same node. Ideal for development, testing, and small deployments.

2. **Separate Mode**: Dedicated nodes for controller and broker roles:
   - **Controller Nodes**: Manage metadata, handle leadership, and maintain cluster state
   - **Broker Nodes**: Handle message storage and client requests

3. **Client Mode**: For applications that produce or consume messages from Kafka

### Node ID Management

In KRaft mode, every node must have a unique ID:

- For combined mode, use a single ID (default: 1)
- For controller-only nodes, use low numbers (e.g., 1, 2, 3)
- For broker-only nodes, use different numbers that don't conflict with controllers
- **Important**: In broker-only mode, the node ID must NOT be included in the controller quorum voters list

### Cluster ID Management

All nodes in a Kafka cluster must share the same cluster ID:

- When setting up a new cluster, the ID is generated automatically for the first controller
- Subsequent nodes must use the same cluster ID value
- You can retrieve the cluster ID from the controller node with: `cat $FLOX_ENV_CACHE/kafka-config/cluster_id`

## 🔍 How It Works

### 🌐 Configuration Management

1. **Hash-Based Configuration Detection**:
   - Generates a unique hash of your configuration
   - Automatically detects configuration changes
   - Resets Kafka state when necessary for clean restarts

2. **Dynamic IP Detection**:
   - Automatically detects network interfaces
   - Falls back to localhost if detection fails
   - Allows manual override via environment variables

3. **KRaft Mode Validation**:
   - Ensures proper node ID separation for broker and controller roles
   - Validates controller quorum settings
   - Prevents common configuration errors

### 🛠️ Environment Variable Handling

This environment accepts pre-set environment variables:

- Kafka-specific variables (e.g., `KAFKA_MODE`, `KAFKA_NODE_ID`) set before activation take precedence
- Defaults are only applied when variables aren't already defined
- Supports both environment variables and manifest.toml configuration

### 📂 Directory Structure

The environment organizes Kafka data and logs in consistent locations:

- `$FLOX_ENV_CACHE/kafka-config` - Configuration files
- `$FLOX_ENV_CACHE/kafka-logs` - Kafka service logs
- `$FLOX_ENV_CACHE/data/kafka` - Kafka data storage
- `$FLOX_ENV_CACHE/kafka-message-output` - Client message outputs (when using file mode)
- `$FLOX_ENV_CACHE/kafka-scripts` - Custom processing scripts

## 🔧 Troubleshooting

If you encounter issues with your Kafka setup:

1. **Broker/Controller Communication Issues**:
   - Verify that node IDs are unique across the cluster
   - Ensure controller quorum settings are correct
   - Check that all nodes are using the same cluster ID

2. **Service Startup Problems**:
   - View logs with `flox services logs kafka`
   - Check for errors in `$FLOX_ENV_CACHE/kafka-logs`
   - Verify environment variables with `env | grep KAFKA`

3. **Configuration Conflicts**:
   - If changing modes (e.g., from combined to broker), ensure a clean reset
   - Check that broker node IDs are not included in controller quorum voters
   - Verify IP addresses and ports are correct and available

4. **Client Connection Issues**:
   - Verify bootstrap servers configuration
   - Check network connectivity between client and broker
   - Ensure topics exist before attempting to produce/consume

5. **Common Errors**:

   - `DUPLICATE_BROKER_REGISTRATION`: The broker ID is already registered in the cluster
     - Solution: Use a different node ID or clean up the existing registration

   - `NODE_ID_MISSING_FROM_VOTERS`: In controller mode, the node ID must be in the voters list
     - Solution: Ensure the controller node ID is included in the controller quorum voters

   - `NODE_ID_IN_VOTERS`: In broker-only mode, the node ID must NOT be in the voters list
     - Solution: Use a different node ID for the broker that doesn't conflict with controllers

   - `Error while fetching metadata with correlation id`: Connection issue between client and broker
     - Solution: Check network connectivity and broker availability

## 🌐 Networking Considerations

For a production Kafka deployment:

1. **Internal vs. External Communication**:
   - Set `KAFKA_HOST` to the internal IP for node-to-node communication
   - Configure `advertised.listeners` appropriately for client communication
   - Consider network security groups and firewall rules

2. **Port Requirements**:
   - Broker port (default: 9092): For client and inter-broker communication
   - Controller port (default: 9093): For controller-to-controller communication

3. **Multi-Datacenter Setup**:
   - For geo-distributed deployments, use MirrorMaker 2.0
   - Configure separate clusters with appropriate networking

## 💻 System Compatibility

This environment works on:
- Linux (ARM64, x86_64)
- macOS (ARM64, x86_64)

## 📚 Additional Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation)
- [Kafka KRaft Mode](https://kafka.apache.org/documentation/#kraft)
- [Kafka Quickstart](https://kafka.apache.org/quickstart)
- [Kafka Operations](https://kafka.apache.org/documentation/#operations)
- [Kafka Configuration](https://kafka.apache.org/documentation/#configuration)

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Input- and path-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT
