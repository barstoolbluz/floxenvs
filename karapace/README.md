# Karapace - Schema Registry & REST Proxy for Apache Kafka

Flox environment providing [Karapace](https://karapace.io) - an open-source Apache Kafka Schema Registry and REST Proxy implementation compatible with Confluent Schema Registry API.

## Features

- **Schema Registry** (port 8081): Centralized schema management for Avro, JSON Schema, and Protobuf
- **REST Proxy** (port 8082): RESTful interface for Kafka operations
- **Composable**: Designed to work with `kafka` or `kafka-local` environments
- **Service-oriented**: Run as background services with `flox services`

## Quick Start

### Standalone Usage

```bash
# Activate environment
flox activate

# Start both services
flox services start

# Or start individually
flox services start karapace-registry
flox services start karapace-rest

# Check service status
flox services status

# View logs
flox services logs karapace-registry
flox services logs karapace-rest
```

### Composed with Kafka

Create a master environment that includes both Kafka and Karapace:

**kafka-with-schema-registry/.flox/env/manifest.toml:**
```toml
[include]
environments = [
    { dir = "../kafka" },
    { dir = "../karapace" }
]
```

Then activate and start all services:

```bash
cd kafka-with-schema-registry
flox activate -s  # Activates and starts Kafka + Karapace services
```

## Configuration

Override default settings via environment variables:

```bash
# Kafka connection
KARAPACE_BOOTSTRAP_URI="kafka-host:9092" flox activate

# Schema Registry settings
KARAPACE_REGISTRY_HOST="0.0.0.0" flox activate
KARAPACE_REGISTRY_PORT="8081" flox activate

# REST Proxy settings
KARAPACE_REST_HOST="0.0.0.0" flox activate
KARAPACE_REST_PORT="8082" flox activate

# Schema topic
KARAPACE_TOPIC_NAME="_schemas" flox activate

# Log level
KARAPACE_LOG_LEVEL="DEBUG" flox activate
```

### Auto-detection with Kafka Environments

When composed with `kafka` or `kafka-local`, Karapace automatically detects Kafka connection settings:

- Reads `$KAFKA_HOST` and `$KAFKA_PORT` from Kafka environment
- Falls back to `$BOOTSTRAP_SERVERS` if available
- Uses `localhost:9092` as final default

## Usage Examples

### Register a Schema

```bash
# Register an Avro schema
curl -X POST http://localhost:8081/subjects/my-topic-value/versions \
  -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  -d '{
    "schema": "{\"type\":\"record\",\"name\":\"User\",\"fields\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"age\",\"type\":\"int\"}]}"
  }'
```

### List Schemas

```bash
# List all subjects
curl http://localhost:8081/subjects

# Get schema versions
curl http://localhost:8081/subjects/my-topic-value/versions
```

### REST Proxy - Produce Message

```bash
# Produce via REST Proxy
curl -X POST http://localhost:8082/topics/my-topic \
  -H "Content-Type: application/vnd.kafka.json.v2+json" \
  -d '{
    "records": [
      {"value": {"name": "Alice", "age": 30}}
    ]
  }'
```

### REST Proxy - Create Consumer

```bash
# Create consumer
curl -X POST http://localhost:8082/consumers/my-group \
  -H "Content-Type: application/vnd.kafka.v2+json" \
  -d '{
    "name": "my-consumer",
    "format": "json",
    "auto.offset.reset": "earliest"
  }'
```

## Service Management

```bash
# Start services
flox services start                    # Start both
flox services start karapace-registry  # Schema Registry only
flox services start karapace-rest      # REST Proxy only

# Stop services
flox services stop
flox services stop karapace-registry
flox services stop karapace-rest

# Restart
flox services restart
flox services restart karapace-registry

# Status
flox services status

# Logs
flox services logs karapace-registry
flox services logs karapace-rest --follow  # Follow mode
```

## Configuration Files

Generated config files stored in `$FLOX_ENV_CACHE/karapace-config/`:

- `karapace-registry.json` - Schema Registry configuration
- `karapace-rest.json` - REST Proxy configuration

Logs stored in `$FLOX_ENV_CACHE/karapace-logs/`:

- `registry.log` - Schema Registry logs
- `rest.log` - REST Proxy logs

## Architecture

```
┌─────────────────┐
│   Kafka Broker  │
│   (port 9092)   │
└────────┬────────┘
         │
    ┌────┴────┬─────────────┐
    │         │             │
┌───▼────┐ ┌─▼──────────┐ ┌▼───────────┐
│ Schema │ │ REST Proxy │ │   Clients  │
│Registry│ │ (port 8082)│ │            │
│(8081)  │ └────────────┘ └────────────┘
└────────┘
```

## Compatibility

- **Kafka Versions**: Compatible with Apache Kafka 2.x and 3.x
- **API Compatibility**: Confluent Schema Registry 6.1.1 API
- **Schema Formats**: Avro, JSON Schema, Protobuf

## Requirements

- **Build**: Karapace must be built first:
  ```bash
  cd /home/daedalus/dev/builds/build-karapace
  flox build karapace
  ```

- **Kafka**: Requires running Kafka cluster (compose with `kafka` or `kafka-local` environment)

## Troubleshooting

### Schema Registry Won't Start

Check Kafka connectivity:
```bash
# Verify Kafka is running
curl -s http://localhost:9092 || echo "Kafka not reachable"

# Check bootstrap URI
flox activate -- bash -c 'echo $KARAPACE_BOOTSTRAP_URI'

# View logs
flox services logs karapace-registry
```

### REST Proxy Errors

```bash
# Check service status
flox services status karapace-rest

# View detailed logs
tail -f $FLOX_ENV_CACHE/karapace-logs/rest.log
```

### Connection Refused

Ensure services are started:
```bash
flox services status
flox services start  # If not running
```

## Links

- **Karapace Documentation**: https://karapace.io/docs
- **GitHub Repository**: https://github.com/Aiven-Open/karapace
- **API Documentation**: https://karapace.io/docs/api-reference
- **Schema Registry API**: https://docs.confluent.io/platform/current/schema-registry/develop/api.html

## License

Karapace is licensed under Apache License 2.0.
