# Node-RED - Interactive Environment

A fully-featured Node-RED low-code programming environment with an interactive configuration wizard. Perfect for IoT, event-driven applications, and workflow automation with visual programming.

## Features

- 🎯 **Interactive Configuration Wizard** - gum-based guided setup
- 🎨 **Dashboard 2.0** - Built-in visualization and UI builder
- 💾 **Flexible Context Storage** - Memory, File, or Redis
- 🔧 **Projects Feature** - Git integration within the editor
- 🔒 **Security First** - Authentication controls and credential encryption
- 📦 **Custom Nodes** - Minimal, Common, or Custom package installation
- 🌐 **Redis Composition** - Optional HA/clustering support
- 🔄 **Reconfigurable** - Easy reconfiguration via wizard

## Quick Start

### 1. Activate the Environment

```bash
cd nodered
flox activate -s
```

The interactive wizard will guide you through:
- Server port and listen address configuration
- Admin authentication setup
- HTTP node authentication (optional)
- Context storage selection (Memory/File/Redis)
- Custom nodes installation (Minimal/Common/Custom)
- Projects feature (Git integration)

### 2. Access Node-RED

Once services start, access the editor:
```
http://localhost:1880
```

Access the dashboard:
```
http://localhost:1880/ui
```

Default credentials (if authentication enabled):
- Username: `admin`
- Password: `admin`

### 3. View Configuration

```bash
nodered-info
```

### 4. Reconfigure

```bash
nodered-reconfigure
```

Runs the wizard again and restarts services with new settings.

## Architecture

Node-RED is a flow-based, low-code programming tool for wiring together hardware devices, APIs, and online services.

### Context Storage Options

**Memory (Default)**:
- Fast performance
- No persistence (lost on restart)
- Best for: Development, testing

**File**:
- Persistent across restarts
- No external dependencies
- Best for: Local development, standalone deployments

**Redis**:
- Persistent and clustered
- Required for HA deployments
- Enables state sharing across multiple instances
- Best for: Production, high availability

### Projects Feature

When enabled, Node-RED provides Git integration directly in the editor:
- Version control your flows
- Commit, push, pull from the UI
- Collaborate with teams
- Choose Manual or Auto workflow mode

**Manual mode** (recommended): Explicit commit/push actions
**Auto mode**: Automatically commits on deploy

## Configuration Options

### Server

```bash
# Set via wizard or override at runtime
NODERED_PORT=1880
NODERED_HOST=0.0.0.0
```

### Authentication

**Admin Authentication** (Editor access):
- Username and password required to access editor
- Passwords hashed with bcrypt

**HTTP Node Authentication** (Flow endpoints):
- Protects HTTP endpoints created by HTTP In nodes
- Basic authentication

### Context Storage

Choose during wizard setup:
- **Memory**: No external dependencies
- **File**: Stored in `$FLOX_ENV_CACHE/nodered-data`
- **Redis**: Requires Redis connection details

### Custom Nodes

**Minimal** (Default):
- `@flowfuse/node-red-dashboard` - Dashboard 2.0

**Common** (Recommended):
- Dashboard 2.0
- Email (`node-red-node-email`)
- InfluxDB (`node-red-contrib-influxdb`)
- MySQL (`node-red-node-mysql`)
- PostgreSQL (`node-red-node-postgres`)

**Custom**:
- Specify your own space-separated list of npm packages

## Runtime Configuration Override

Override configuration at activation time:

```bash
# Custom port
NODERED_PORT=8080 flox activate -s

# Custom flow file name
NODERED_FLOW_FILE=production-flows.json flox activate -s

# Disable authentication (not recommended)
NODERED_ADMIN_AUTH_ENABLED=false flox activate -s

# Use Redis context storage
NODERED_CONTEXT_STORAGE=redis \
REDIS_HOST=redis.example.com \
REDIS_PORT=6379 \
flox activate -s
```

## Commands

### Configuration

```bash
nodered-info              # Show current configuration
nodered-reconfigure       # Run wizard again and restart
nodered-hash-password     # Generate bcrypt password hash
```

### Service Management

```bash
flox services status              # Check service status
flox services logs nodered        # View Node-RED logs
flox services restart             # Restart services
flox services stop                # Stop services
```

### Direct Node-RED Commands

```bash
node-red                  # Start Node-RED manually
node-red-admin            # Admin CLI tool
node-red-admin hash-pw    # Generate password hash
```

## Directory Structure

```
$FLOX_ENV_CACHE/
├── nodered-config/           # Configuration files
├── nodered-data/             # User data, flows, projects
│   ├── flows.json           # Your flows
│   ├── flows_cred.json      # Encrypted credentials
│   ├── settings.js          # Generated settings
│   ├── package.json         # Custom node dependencies
│   ├── node_modules/        # Installed custom nodes
│   └── projects/            # Git-backed projects (if enabled)
├── nodered-logs/            # Log files
└── nodered-credential.key   # 🔒 CRITICAL: Backup this file!
```

## Security Considerations

### Credential Secret

**CRITICAL**: The credential secret encrypts/decrypts all credentials stored in flows.

- Location: `$FLOX_ENV_CACHE/nodered-credential.key`
- **Without this key, stored credentials are UNRECOVERABLE**
- Automatically generated on first run
- Back up immediately after first activation
- Store backup securely (password manager, encrypted vault)

### Authentication

**Development**:
- Basic authentication with default credentials is fine
- Change password via wizard or environment variable

**Production**:
- Always enable authentication
- Use strong, unique passwords
- Consider HTTPS (configure via environment variables)
- Use OAuth/SSO if available (requires custom configuration)

### Password Hashing

Generate bcrypt hashes for secure password storage:

```bash
nodered-hash-password
```

Or use directly:
```bash
node-red-admin hash-pw
```

## Projects (Git Integration)

### Enabling Projects

Projects are enabled by default in the interactive environment. The wizard asks if you want to enable them.

### Using Projects

1. In Node-RED editor, click the menu (≡) → Projects → New
2. Name your project and initialize Git repository
3. Edit flows normally
4. Use the Projects sidebar to:
   - View changes
   - Commit with messages
   - Push/pull to remote repositories
   - Switch branches

### Workflow Modes

**Manual** (recommended for learning):
- You explicitly commit and push changes
- See all changes before committing
- Full control over Git operations

**Auto**:
- Automatically commits on every deploy
- Less control but more convenient
- Commit messages auto-generated

## Use Cases

### IoT Device Control

```
MQTT Sensors → Node-RED Flows → Device Actions
                     ↓
                Dashboard UI
```

### API Integration

```
REST APIs → Transform → Database
              ↓
         Dashboard
```

### Home Automation

```
Sensors → Logic Flows → Smart Devices
              ↓
         Control Dashboard
```

### Data Pipeline

```
Data Sources → Processing → Storage
                   ↓
              Visualization
```

## Custom Nodes Installation

### During Setup

Choose your installation option in the wizard:
- **Minimal**: Dashboard only
- **Common**: Dashboard + common database/email nodes
- **Custom**: Specify your own packages

### After Setup

Install additional nodes manually:

```bash
# Activate environment
flox activate

# Navigate to userDir
cd $NODERED_DATA_DIR

# Install nodes
npm install node-red-node-twitter
npm install node-red-contrib-mongodb3

# Restart Node-RED
flox services restart
```

### Via Palette Manager

In Node-RED editor:
1. Menu (≡) → Manage palette
2. Install tab
3. Search for nodes
4. Install

## Dashboard

Node-RED Dashboard 2.0 (`@flowfuse/node-red-dashboard`) is installed by default.

### Accessing Dashboard

```
http://localhost:1880/ui
```

### Dashboard Nodes

Available in the palette:
- **Inputs**: Button, Switch, Slider, Text Input, etc.
- **Outputs**: Chart, Gauge, Text, LED, etc.
- **Layouts**: Group, Tab
- **Control**: Link Call, Template

### Building Dashboards

1. Add dashboard nodes to your flow
2. Configure group and tab
3. Deploy
4. Access `/ui` to view

## Troubleshooting

### Services Not Starting

```bash
# Check service status
flox services status

# Check logs
flox services logs nodered

# Verify settings
nodered-info
```

### Cannot Access Editor

1. Verify Node-RED is running: `flox services status`
2. Check port: `nodered-info`
3. Check authentication settings
4. Try: `http://0.0.0.0:1880` or `http://127.0.0.1:1880`

### Authentication Issues

Generate new password hash:
```bash
nodered-hash-password
```

Then reconfigure with new credentials.

### Custom Nodes Not Working

```bash
# Check if nodes installed
ls $NODERED_DATA_DIR/node_modules

# Reinstall
cd $NODERED_DATA_DIR
npm install <package-name>

# Restart
flox services restart
```

### Credential Secret Lost

**If you lose the credential secret**:
- Stored credentials in flows become unrecoverable
- You must manually re-enter all credentials in flows
- Flows will show errors until credentials restored

**To reset**:
```bash
# Stop services
flox services stop

# Remove old key
rm $FLOX_ENV_CACHE/nodered-credential.key

# Remove old credentials
rm $NODERED_DATA_DIR/flows_cred.json

# Reactivate (new key generated)
flox activate -s

# Re-enter all credentials in your flows
```

### Redis Context Storage Issues

```bash
# Verify Redis is running
flox services status

# Check Redis connection
redis-cli -h 127.0.0.1 -p 16379 PING

# Check Node-RED logs
flox services logs nodered
```

## Migrating to Production

### Save Your Work

1. **Backup credential secret**: Copy `$FLOX_ENV_CACHE/nodered-credential.key`
2. **Export flows**: Menu → Export → All flows
3. **Note custom nodes**: Check `package.json` in userDir
4. **Backup projects**: Push to Git remote if using Projects

### Move to Headless Environment

Use the **nodered-headless** environment for production:

```bash
cd ../nodered-headless

# Configure via environment variables
NODERED_PORT=80 \
NODERED_ADMIN_PASSWORD="strong-password" \
NODERED_CONTEXT_STORAGE=redis \
REDIS_HOST=prod-redis \
NODERED_LOG_AUDIT=true \
flox activate -s
```

See `nodered-headless/README.md` for full production deployment guide.

## Composed Environments

This environment includes:
- **redis-headless** - Redis server (optional, used if Redis context storage selected)

## Related Environments

- **nodered-headless** - Headless automation environment for production/CI/CD
- **redis** / **redis-headless** - Redis cache/queue
- **n8n** / **n8n-headless** - Alternative workflow automation (cloud-focused)

## Resources

- [Node-RED Documentation](https://nodered.org/docs/)
- [Node-RED Flows Library](https://flows.nodered.org/)
- [Node-RED Dashboard 2.0](https://dashboard.flowfuse.com/)
- [Node-RED Forum](https://discourse.nodered.org/)
- [Node-RED GitHub](https://github.com/node-red/node-red)
- [Creating Custom Nodes](https://nodered.org/docs/creating-nodes/)

## Support

For issues with this Flox environment:
- Check the main README at the repository root
- Review the manifest: `.flox/env/manifest.toml`

For Node-RED-specific issues:
- [Node-RED Documentation](https://nodered.org/docs/)
- [Node-RED Forum](https://discourse.nodered.org/)
