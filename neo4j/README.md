# 🚀 Flox Environment for Neo4j Graph Database

This `neo4j` environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

## ✨ Features

- Dynamic environment variable configuration for Neo4j settings
- Runtime override capabilities for all configuration options
- Automatic directory and configuration management
- Cross-platform compatibility (Linux x86_64 and ARM64, macOS x86_64 and ARM64)
- Flox service management for Neo4j
- Default configurations that "just work" with minimal setup
- No interactive wizards or prompts

## 🧰 Included Tools

The environment includes:

- `neo4j` - The powerful graph database platform

## 🏁 Getting Started

### 📋 Prerequisites

- [Flox](https://flox.dev/get) installed on your system
- That's it.

### 💻 Installation & Activation

Get started with:

```sh
# Clone the repo
git clone https://github.com/barstoolbluz/floxenvs && cd floxenvs/neo4j

# Activate the environment with defaults
flox activate -s
```

This will:
- Create all required Neo4j directories
- Generate Neo4j configuration file
- Start Neo4j on localhost:7474 (HTTP) and localhost:7687 (Bolt)
- Display connection information

## 📝 Usage Scenarios

### Basic Activation with Defaults

Start Neo4j with sensible defaults:

```bash
flox activate -s
```

Defaults:
- Host: `localhost`
- Bolt Port: `7687`
- HTTP Port: `7474`
- Username: `neo4j`
- Password: `neo4jpass`
- Data Directory: `$FLOX_ENV_CACHE/neo4j-data`

### Custom Network Configuration

Configure Neo4j for network access:

```bash
# Listen on all interfaces with custom ports
NEO4J_HOST="0.0.0.0" \
NEO4J_PORT="7688" \
NEO4J_HTTP_PORT="7475" \
flox activate -s
```

One-liner:
```bash
NEO4J_HOST=0.0.0.0 NEO4J_PORT=7688 NEO4J_HTTP_PORT=7475 flox activate -s
```

### Custom Authentication

Specify custom credentials:

```bash
# Use custom username and password
NEO4J_USER="admin" \
NEO4J_PASSWORD="secure-password-123" \
flox activate -s
```

One-liner:
```bash
NEO4J_USER=admin NEO4J_PASSWORD=secure-password-123 flox activate -s
```

### Custom Data Directory

Specify where Neo4j data should be stored:

```bash
# Use a specific directory for Neo4j data
NEO4J_DIR="/path/to/my/neo4j-data" \
flox activate -s
```

One-liner:
```bash
NEO4J_DIR=/path/to/my/neo4j-data flox activate -s
```

### Complete Custom Configuration

Combine multiple settings for full control:

```bash
# Full custom configuration
NEO4J_HOST="0.0.0.0" \
NEO4J_PORT="7688" \
NEO4J_HTTP_PORT="7475" \
NEO4J_USER="admin" \
NEO4J_PASSWORD="secure-password-123" \
NEO4J_DIR="/home/user/neo4j-data" \
flox activate -s
```

One-liner:
```bash
NEO4J_HOST=0.0.0.0 NEO4J_PORT=7688 NEO4J_HTTP_PORT=7475 NEO4J_USER=admin NEO4J_PASSWORD=secure-password-123 NEO4J_DIR=/home/user/neo4j-data flox activate -s
```

### Managing Neo4j Service

```bash
# Start Neo4j service
flox services start

# Check service status
flox services status

# View service logs
flox services logs neo4j

# Follow logs in real-time
flox services logs --follow neo4j

# Stop service
flox services stop
```

### Using the Helper Function

```bash
# Activate environment
flox activate

# Display connection information
neo4j-info
```

## 🔍 Configuration Variables

All configuration is done via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `NEO4J_HOST` | `localhost` | Host to bind Neo4j server |
| `NEO4J_PORT` | `7687` | Port for Bolt protocol |
| `NEO4J_HTTP_PORT` | `7474` | Port for HTTP/Browser interface |
| `NEO4J_USER` | `neo4j` | Database username |
| `NEO4J_PASSWORD` | `neo4jpass` | Database password |
| `NEO4J_DIR` | `$FLOX_ENV_CACHE/neo4j-data` | Neo4j data directory location |

## 🔍 How It Works

### 🗄️ Directory Management

1. **Automatic Creation**:
   - Creates directories at `$NEO4J_DIR` (default: `$FLOX_ENV_CACHE/neo4j-data`)
   - Subdirectories: `data/`, `logs/`, `conf/`, `run/`
   - All directories created with 700 permissions (user-only access)

2. **Configuration Generation**:
   - Automatically creates `neo4j.conf` on activation
   - Configuration reflects current environment variable values
   - Re-generates on each activation to pick up changes

3. **Service Integration**:
   - Neo4j service uses `NEO4J_HOME` from environment
   - All settings available to the service process
   - Logs written to `$NEO4J_DIR/logs`

### 🌐 Network Modes

1. **Localhost Only** (`NEO4J_HOST=localhost` or `127.0.0.1`):
   - Only accessible from the local machine
   - More secure for development work
   - Access via: `http://localhost:7474`

2. **Network Access** (`NEO4J_HOST=0.0.0.0`):
   - Accessible from any network interface
   - Useful for remote work or team collaboration
   - Access via: `http://<your-ip>:7474`
   - **Security**: Always use a strong password for network access

### 🔐 Security

- Authentication enabled by default
- Data directory permissions set to 700 (user-only)
- Default password should be changed for production use
- Credentials passed via environment variables (not stored in config files)

### 📂 Directory Structure

The environment organizes data in consistent locations:

- `$NEO4J_DIR/data` - Database data files
- `$NEO4J_DIR/logs` - Neo4j log files
- `$NEO4J_DIR/conf` - Neo4j configuration
- `$NEO4J_DIR/run` - Runtime files

## 🔧 Troubleshooting

Common issues and solutions:

1. **Service Won't Start**:
   - Check if ports are already in use: `netstat -an | grep 7474`
   - View logs: `flox services logs neo4j`
   - Verify environment variables: `env | grep NEO4J`

2. **Can't Access Neo4j Browser**:
   - Verify service is running: `flox services status`
   - Check firewall settings for network access
   - Ensure correct URL: `http://localhost:7474`
   - Try IP address instead of hostname

3. **Authentication Issues**:
   - Check credentials match environment variables
   - Default is `neo4j` / `neo4jpass`
   - Verify with: `echo $NEO4J_USER $NEO4J_PASSWORD`

4. **Data Directory Issues**:
   - Check permissions: `ls -la $NEO4J_DIR`
   - Ensure path is writable
   - Verify no other Neo4j instance is using the directory

5. **Port Conflicts**:
   - Use custom ports: `NEO4J_PORT=7688 NEO4J_HTTP_PORT=7475 flox activate -s`
   - Check what's using the port: `lsof -i :7474`

## 🌐 Production Deployment Tips

For production or team use:

1. **Security**:
   - Always use strong, unique passwords
   - Restrict network access via firewall rules
   - Consider HTTPS reverse proxy (nginx, Caddy)
   - Regularly update Neo4j: monitor for security patches

2. **Performance**:
   - Allocate sufficient memory for graph operations
   - Use SSD storage for data directory
   - Monitor resource usage and logs
   - Consider dedicated data directory per project

3. **Backup**:
   - Regularly backup `$NEO4J_DIR/data`
   - Use Neo4j's built-in backup tools
   - Test restore procedures
   - Document environment configurations

4. **Monitoring**:
   - Monitor logs: `flox services logs --follow neo4j`
   - Check service health via HTTP API
   - Set up alerts for critical issues
   - Track query performance

## 💻 System Compatibility

This environment works on:
- Linux (ARM64, x86_64)
- macOS (ARM64, x86_64)

## 📚 Additional Resources

- [Neo4j Documentation](https://neo4j.com/docs/)
- [Cypher Query Language](https://neo4j.com/docs/cypher-manual/current/)
- [Neo4j Browser Guide](https://neo4j.com/docs/browser-manual/current/)
- [Graph Database Concepts](https://neo4j.com/docs/getting-started/current/graphdb-concepts/)

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Input- and path-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT
