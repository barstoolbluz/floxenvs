# Apache Kafka (KRaft Mode) - Interactive Environment

Interactive development environment for Apache Kafka using KRaft mode (no ZooKeeper required).

## Features

- **KRaft Mode Support** - Kafka without ZooKeeper using Raft consensus protocol
- **Multiple Deployment Modes** - Combined (single-node), Controller-only, Broker-only, or Client-only
- **Interactive Configuration Wizard** - Guided setup using `gum` for optimal UX
- **Cross-Shell Compatibility** - Works with Bash, ZSH, and Fish shells
- **Helper Functions** - Convenient commands for common Kafka operations
- **Service Management** - Integrated Flox services for Kafka server lifecycle
- **Persistent Storage** - Configuration and data stored in `$FLOX_ENV_CACHE`

## Quick Start

### First Time Setup

```bash
cd kafka
flox activate
# The configuration wizard runs automatically on first activation
# Follow the prompts to configure your Kafka deployment
```

### Start Kafka Service

```bash
# Start with services enabled
flox activate -s

# Or start service from within activated environment
flox services start kafka
```

### Using Kafka

```bash
# Create a topic
kreate my-topic 3 1

# Produce messages
produce my-topic

# Consume messages
konsume my-topic

# List all topics
list
```

## Deployment Modes

The environment supports four deployment modes:

1. **kraft-combined** (default)
   - Single-node deployment with combined controller and broker roles
   - Ideal for development and testing
   - Default ports: 9092 (broker), 9093 (controller)

2. **kraft-controller**
   - Controller-only node for distributed KRaft clusters
   - Participates in metadata quorum but doesn't handle client requests
   - Requires configuring quorum voters

3. **kraft-broker**
   - Broker-only node for distributed KRaft clusters
   - Handles client produce/consume requests
   - Connects to remote controllers

4. **client**
   - Client-only mode for connecting to existing Kafka clusters
   - No local Kafka server started
   - Provides helper functions to interact with remote clusters

## Configuration

### Interactive Wizard

On first activation, the configuration wizard runs automatically. It will prompt you to configure:

- **Deployment Mode**: kraft-combined, kraft-controller, kraft-broker, or client
- **Network Settings**: Host, broker port, controller port
- **Cluster Settings**: Node ID, cluster ID, process roles
- **Advanced Options**: Log directories, JMX settings, performance tuning

### Reconfiguring

To reconfigure your environment, run:

```bash
bootstrap
```

This will re-run the configuration wizard and update your saved settings.

### Runtime Override (Advanced)

Only one variable supports runtime override:

| Variable | Default | Description |
|----------|---------|-------------|
| `KAFKA_TIMEOUT` | 5 | Timeout in seconds for connectivity checks |

Example:

```bash
# Use shorter timeout for faster feedback
KAFKA_TIMEOUT=2 flox activate
```

### Configuration Persistence

- Configuration saved to: `$FLOX_ENV_CACHE/config/kafka_config.sh`
- Kafka data stored in: `$FLOX_ENV_CACHE/data/kafka-logs/`
- Server logs available at: `$FLOX_ENV_CACHE/logs/kafka.log`

## Helper Functions

Convenient commands available in all shells (bash/zsh/fish):

### Topic Management

- **`kreate <topic-name> [partitions] [replication-factor]`**
  - Create a new Kafka topic
  - Example: `kreate my-topic 3 1`
  - Note: Replication factor cannot exceed broker count

- **`list`**
  - List all topics in the cluster

- **`describe <topic-name>`**
  - Show detailed information about a topic

### Data Operations

- **`produce <topic-name>`**
  - Start interactive producer console for a topic
  - Type messages and press Enter to send
  - Ctrl+C to exit

- **`konsume <topic-name> [offset]`**
  - Start consumer to read messages from a topic
  - Default: reads from beginning (`--from-beginning`)
  - Specify offset: `earliest`, `latest`, or numeric offset

### Cluster Information

- **`status`**
  - Show Kafka cluster status and configuration

- **`topos`**
  - Display cluster topology and broker information

### Environment Management

- **`bootstrap`**
  - Re-run the configuration wizard
  - Use this to change your Kafka deployment mode or settings

- **`info`**
  - Show comprehensive environment information
  - Displays configuration, available commands, and quick start guide

- **`readme`**
  - Display this README file in the terminal

### Service Management

Use standard Flox service commands:

```bash
# Start Kafka service
flox services start kafka

# Stop Kafka service
flox services stop kafka

# Restart Kafka service
flox services restart kafka

# View service status
flox services status

# Tail service logs
flox services logs kafka
```

## Known Limitations

### ZSH Argument Quoting (Issue #12)

**ZSH users**: Topic names and arguments with spaces are not supported due to word-splitting in the `bash -c` wrapper.

❌ **Doesn't work:**
```bash
kreate "topic with spaces" 3 2
produce "my topic name"
```

✅ **Works (use hyphens or underscores):**
```bash
kreate my-topic 3 2
kreate user_events 3 2
produce order-stream
```

This follows standard Kafka naming conventions. Other shells (bash, fish) are unaffected.

### Controller Configuration

- **Maximum controllers**: 50 (prevents accidental infinite loops)
- **Numeric validation**: Controller IDs and port numbers must be valid integers
- **Replication limits**: Replication factor cannot exceed available broker count

## Troubleshooting

### Service Won't Start

```bash
# Check service status
flox services status

# View detailed logs
flox services logs kafka

# Check if port is already in use (default: 9092)
lsof -i :9092

# Review configuration
info
```

### Connection Refused

```bash
# Verify Kafka is running
flox services status

# Check bootstrap server configuration
status

# Test connectivity with longer timeout
KAFKA_TIMEOUT=10 flox activate -- status
```

### Topic Creation Fails

```bash
# Ensure replication factor doesn't exceed broker count
# For single-node (kraft-combined): replication factor must be 1
kreate my-topic 3 1  # 3 partitions, 1 replica

# Verify topic name (no spaces in ZSH)
kreate my-topic-name 3 1  # use hyphens instead of spaces
```

### Reconfigure Environment

```bash
# Re-run the configuration wizard
flox activate -- bootstrap

# Or from within an activated environment
bootstrap
```

### Clean Kafka Data

```bash
# WARNING: Deletes all topics and messages
rm -rf "$FLOX_ENV_CACHE/data/kafka-logs"
# Restart environment to regenerate
```

## Directory Structure

```
$FLOX_ENV_CACHE/
├── config/
│   ├── kafka_config.sh          # Saved configuration
│   ├── server.properties        # Kafka server config
│   └── controller.properties    # Controller config (if applicable)
├── data/
│   └── kafka-logs/              # Kafka data and metadata
├── logs/
│   └── kafka.log                # Server logs
└── helper-functions/
    └── helper-functions.sh      # Helper function definitions
```

## Advanced Usage

### Multi-Node KRaft Cluster

This environment uses an interactive wizard. For multi-node clusters:

**On each node:**
1. Run `flox activate`
2. When prompted, select the appropriate mode:
   - **kraft-controller** for controller-only nodes
   - **kraft-broker** for broker-only nodes
   - **kraft-combined** for combined nodes
3. Use the **same Cluster ID** across all nodes
4. Configure unique Node IDs for each node
5. Set controller quorum voters correctly

### Client-Only Mode

To connect to an existing Kafka cluster:

1. Run `flox activate`
2. Select **client** mode when prompted
3. Enter your bootstrap servers (e.g., `kafka1:9092,kafka2:9092`)
4. Use helper functions to interact with the cluster:

```bash
kreate my-topic 3 2
produce my-topic
konsume my-topic
```

## Composition

This environment can be included in other Flox environments:

```toml
[include]
environments = [
  { remote = "yourorg/kafka" },
]
```

All helper functions (kreate, list, produce, etc.) will be available in the composing environment.

## Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [KRaft Mode Overview](https://kafka.apache.org/documentation/#kraft)
- [Kafka Quick Start](https://kafka.apache.org/quickstart)

## Version

- **Kafka**: 3.x (provided by nixpkgs)
- **Java**: OpenJDK 17
- **Environment**: Flox-managed declarative environment

---

**Note**: This is an interactive development environment. For production deployments, consider the headless variant or proper Kafka cluster configuration with appropriate security, monitoring, and high availability settings.
