# Node-RED - Headless Environment

Production-ready Node-RED environment with zero interaction, configured entirely via environment variables. Perfect for CI/CD pipelines, Docker deployments, and automated infrastructure.

## Features

- 🚀 **Zero Interaction** - Configure entirely via environment variables
- 🔒 **Production Hardened** - Editor disable option, audit logging, HTTPS support
- 💾 **Flexible Storage** - Memory, File, or Redis context storage
- 📊 **Dashboard Included** - Dashboard 2.0 pre-installed
- 🔧 **Git Workflow** - Projects feature optional (disabled by default for CI/CD)
- 🎯 **CI/CD Ready** - Designed for automation and orchestration
- ⚡ **25+ Environment Variables** - Complete runtime configurability
- 🌐 **Redis Composition** - Included for context storage option

## Quick Start

### Basic Deployment

```bash
cd nodered
flox activate -s
```

Access Node-RED at `http://localhost:1880` with credentials:
- Username: `admin`
- Password: `admin`

Dashboard at: `http://localhost:1880/ui`

### Production Deployment

```bash
cd nodered

NODERED_PORT=80 \
NODERED_ADMIN_PASSWORD="secure-password" \
NODERED_CONTEXT_STORAGE=redis \
REDIS_HOST=redis.prod.local \
NODERED_LOG_AUDIT=true \
NODERED_EDITOR_DISABLED=false \
flox activate -s
```

## Architecture

Node-RED is a flow-based programming tool for event-driven applications, IoT, and workflow automation.

### Context Storage Patterns

**Memory** (Default):
- Fast, no persistence
- Lost on restart
- Best for: Stateless flows, CI/CD testing

**File**:
- Persistent across restarts
- No external dependencies
- Best for: Edge devices, standalone

**Redis**:
- Distributed state sharing
- High availability support
- Required for clustering
- Best for: Production, scaled deployments

## Configuration

### Core Settings

```bash
# Server
NODERED_PORT=1880                    # Default: 1880
NODERED_HOST=0.0.0.0                 # Default: 0.0.0.0
NODERED_FLOW_FILE=flows.json         # Default: flows.json
```

### Security

```bash
# Admin authentication (editor access)
NODERED_ADMIN_AUTH_ENABLED=true      # Default: true
NODERED_ADMIN_USER=admin             # Default: admin
NODERED_ADMIN_PASSWORD=admin         # Default: admin
NODERED_ADMIN_PASSWORD_HASH=""       # Override with bcrypt hash

# HTTP node authentication
NODERED_HTTP_AUTH_ENABLED=false      # Default: false
NODERED_HTTP_USER=""                 # Username for HTTP nodes
NODERED_HTTP_PASSWORD=""             # Password for HTTP nodes
NODERED_HTTP_PASSWORD_HASH=""        # Override with bcrypt hash

# Production mode
NODERED_EDITOR_DISABLED=false        # Default: false, set true to disable editor
```

### Context Storage

```bash
# Storage type
NODERED_CONTEXT_STORAGE=memory       # Options: memory, file, redis

# Redis configuration (if NODERED_CONTEXT_STORAGE=redis)
REDIS_HOST=127.0.0.1                 # Default: 127.0.0.1
REDIS_PORT=16379                     # Default: 16379
REDIS_DB=0                           # Default: 0
REDIS_PASSWORD=""                    # Default: (empty)
REDIS_KEY_PREFIX=nodered             # Default: nodered
```

### Projects Feature

```bash
# Git integration in editor
NODERED_PROJECTS_ENABLED=false       # Default: false (disabled for CI/CD)
NODERED_PROJECTS_WORKFLOW_MODE=manual # Options: manual, auto
```

### Logging

```bash
NODERED_LOG_LEVEL=info               # Options: fatal, error, warn, info, debug, trace
NODERED_LOG_AUDIT=false              # Enable audit logging (recommended for production)
NODERED_LOG_METRICS=false            # Enable metrics logging
NODERED_LOG_FILE_PATH=$NODERED_LOG_DIR/nodered.log
```

### Dashboard

```bash
NODERED_DASHBOARD_PATH=/ui           # Default: /ui
```

### Performance

```bash
NODERED_API_MAX_LENGTH=5mb           # Max API request body size
NODERED_FUNCTION_TIMEOUT=0           # Function node timeout (0=no timeout)
NODERED_DEBUG_MAX_LENGTH=1000        # Max debug message length
```

### HTTPS (Optional)

```bash
NODERED_HTTPS_ENABLED=false          # Enable HTTPS
NODERED_HTTPS_KEY_PATH=""            # Path to SSL key
NODERED_HTTPS_CERT_PATH=""           # Path to SSL certificate
```

### Custom Nodes

```bash
# Space-separated list of npm packages
NODERED_INSTALL_NODES="@flowfuse/node-red-dashboard"  # Default: dashboard only

# Examples:
NODERED_INSTALL_NODES="@flowfuse/node-red-dashboard node-red-node-email node-red-contrib-influxdb"
```

## Usage Examples

### Local Development

```bash
# Default settings
flox activate -s
```

### Production Secure Deployment

```bash
# HTTPS, strong auth, Redis context, audit logging
NODERED_PORT=443 \
NODERED_HTTPS_ENABLED=true \
NODERED_HTTPS_KEY_PATH=/certs/key.pem \
NODERED_HTTPS_CERT_PATH=/certs/cert.pem \
NODERED_ADMIN_PASSWORD="$(cat /secrets/admin-password)" \
NODERED_CONTEXT_STORAGE=redis \
REDIS_HOST=redis.prod.local \
REDIS_PASSWORD="$(cat /secrets/redis-password)" \
NODERED_LOG_AUDIT=true \
NODERED_LOG_LEVEL=warn \
flox activate -s
```

### CI/CD Testing

```bash
# Minimal, fast startup for testing
NODERED_ADMIN_AUTH_ENABLED=false \
NODERED_CONTEXT_STORAGE=memory \
NODERED_LOG_LEVEL=error \
flox activate
```

### Edge Device Deployment

```bash
# Persistent file storage, custom nodes
NODERED_PORT=8080 \
NODERED_CONTEXT_STORAGE=file \
NODERED_INSTALL_NODES="@flowfuse/node-red-dashboard node-red-node-email node-red-contrib-gpio" \
flox activate -s
```

### Headless Production (Editor Disabled)

```bash
# No editor access, production locked down
NODERED_EDITOR_DISABLED=true \
NODERED_ADMIN_AUTH_ENABLED=false \
NODERED_CONTEXT_STORAGE=redis \
REDIS_HOST=redis.prod.local \
NODERED_LOG_AUDIT=true \
flox activate -s
```

### Docker Deployment

```bash
# Pre-configure flows, disable editor
NODERED_FLOW_FILE=production-flows.json \
NODERED_EDITOR_DISABLED=true \
NODERED_CONTEXT_STORAGE=redis \
REDIS_HOST=redis \
REDIS_PORT=6379 \
flox activate -s
```

## Commands

### Configuration Inspection

```bash
nodered-info                 # Show complete configuration
```

### Service Management

```bash
flox services status              # Check service status
flox services logs nodered        # View Node-RED logs
flox services restart             # Restart services
flox services stop                # Stop services
```

### Password Generation

```bash
nodered-hash-password             # Generate bcrypt hash
```

Or use directly:
```bash
node-red-admin hash-pw
```

## Password Hashing

Generate bcrypt hashes for secure password storage:

```bash
# Interactive
nodered-hash-password
# Paste password, get hash

# Use hash in environment
NODERED_ADMIN_PASSWORD_HASH='$2b$08$abc...' flox activate -s
```

**Important**: If you provide `NODERED_ADMIN_PASSWORD_HASH`, the `NODERED_ADMIN_PASSWORD` is ignored.

## Directory Structure

```
$FLOX_ENV_CACHE/
├── nodered-config/              # Configuration files
├── nodered-data/                # User data, flows, credentials
│   ├── flows.json              # Your flows
│   ├── flows_cred.json         # Encrypted credentials
│   ├── settings.js             # Generated settings
│   ├── package.json            # Node dependencies
│   └── node_modules/           # Custom nodes
├── nodered-logs/               # Log files
│   └── nodered.log            # Log output
└── nodered-credential.key      # 🔒 CRITICAL: Backup this file!
```

## Security Best Practices

### 1. Credential Secret Backup

```bash
# Location
$FLOX_ENV_CACHE/nodered-credential.key

# Backup immediately
cp $FLOX_ENV_CACHE/nodered-credential.key /secure/backup/location/

# Store securely (password manager, encrypted vault)
```

**Without this key, ALL flow credentials are UNRECOVERABLE.**

### 2. Change Default Passwords

```bash
# Generate secure hash
nodered-hash-password

# Use hash
NODERED_ADMIN_PASSWORD_HASH='$2b$08$...' flox activate -s
```

### 3. Use HTTPS in Production

```bash
NODERED_HTTPS_ENABLED=true
NODERED_HTTPS_KEY_PATH=/certs/key.pem
NODERED_HTTPS_CERT_PATH=/certs/cert.pem
```

### 4. Enable Audit Logging

```bash
NODERED_LOG_AUDIT=true
NODERED_LOG_LEVEL=warn
```

### 5. Disable Editor in Production

```bash
NODERED_EDITOR_DISABLED=true
```

This disables the flow editor entirely. Flows can only be updated by:
- Replacing `flows.json` file
- Deploying via CI/CD
- Using Node-RED Admin API programmatically

### 6. Redis Security

```bash
REDIS_PASSWORD="strong-redis-password"
```

### 7. Network Security

```bash
# Only bind to localhost if behind reverse proxy
NODERED_HOST=127.0.0.1

# Or bind to all interfaces with firewall rules
NODERED_HOST=0.0.0.0
```

## Context Storage Strategies

### Development: Memory

```bash
NODERED_CONTEXT_STORAGE=memory
```

- Fast
- No external dependencies
- State lost on restart
- Good for: Testing, stateless flows

### Production Single Instance: File

```bash
NODERED_CONTEXT_STORAGE=file
```

- Persistent
- No external dependencies
- Single instance only
- Good for: Edge devices, standalone servers

### Production Clustered: Redis

```bash
NODERED_CONTEXT_STORAGE=redis
REDIS_HOST=redis.prod.local
REDIS_PORT=6379
REDIS_PASSWORD="secure-password"
REDIS_KEY_PREFIX=nodered-prod
```

- Distributed state
- Survives restarts
- Shared across instances
- Good for: HA deployments, Kubernetes

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy Node-RED

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Flox
        run: |
          curl -fsSL https://downloads.flox.dev/by-env/stable/install | bash

      - name: Deploy Node-RED
        run: |
          cd nodered
          NODERED_FLOW_FILE=flows.json \
          NODERED_ADMIN_PASSWORD_HASH=${{ secrets.NODERED_ADMIN_HASH }} \
          NODERED_CONTEXT_STORAGE=redis \
          REDIS_HOST=${{ secrets.REDIS_HOST }} \
          REDIS_PASSWORD=${{ secrets.REDIS_PASSWORD }} \
          flox activate -- node-red flows.json
```

### GitLab CI Example

```yaml
deploy:
  stage: deploy
  script:
    - curl -fsSL https://downloads.flox.dev/by-env/stable/install | bash
    - cd nodered
    - |
      NODERED_EDITOR_DISABLED=true \
      NODERED_CONTEXT_STORAGE=redis \
      REDIS_HOST=${REDIS_HOST} \
      REDIS_PASSWORD=${REDIS_PASSWORD} \
      flox activate -s
```

### Docker Example

```dockerfile
FROM ubuntu:22.04

# Install Flox
RUN curl -fsSL https://downloads.flox.dev/by-env/stable/install | bash

# Copy Node-RED environment
COPY nodered /app/nodered
WORKDIR /app/nodered

# Copy flows
COPY flows.json /app/nodered/.flox/cache/nodered-data/

# Expose port
EXPOSE 1880

# Start Node-RED
CMD ["flox", "activate", "-s"]
```

## Monitoring & Troubleshooting

### Check Service Status

```bash
flox services status
```

Expected:
```
nodered  [RUNNING]
redis    [RUNNING]  # If using Redis context storage
```

### View Logs

```bash
# Follow logs
flox services logs nodered

# View log file
tail -f $NODERED_LOG_DIR/nodered.log
```

### Common Issues

#### Cannot Connect to Redis

```bash
# Test Redis connection
redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD PING

# Check Node-RED logs
flox services logs nodered | grep -i redis
```

#### Flows Not Loading

```bash
# Verify flow file exists
ls -l $NODERED_DATA_DIR/$NODERED_FLOW_FILE

# Check permissions
stat $NODERED_DATA_DIR/$NODERED_FLOW_FILE

# Check logs for errors
flox services logs nodered | grep -i error
```

#### Custom Nodes Not Found

```bash
# Check installed nodes
ls $NODERED_DATA_DIR/node_modules

# Reinstall
cd $NODERED_DATA_DIR
npm install <package-name>

# Restart
flox services restart
```

#### Authentication Not Working

```bash
# Verify password hash generation
nodered-hash-password

# Check settings.js
cat $NODERED_DATA_DIR/settings.js | grep -A5 adminAuth
```

## Performance Tuning

### High-Throughput Deployments

```bash
NODERED_API_MAX_LENGTH=50mb
NODERED_FUNCTION_TIMEOUT=60000  # 60 seconds
NODERED_DEBUG_MAX_LENGTH=5000
```

### Resource-Constrained Environments

```bash
NODERED_CONTEXT_STORAGE=memory
NODERED_LOG_LEVEL=error
NODERED_LOG_METRICS=false
NODERED_LOG_AUDIT=false
```

### Production Optimized

```bash
NODERED_CONTEXT_STORAGE=redis
NODERED_LOG_LEVEL=warn
NODERED_LOG_AUDIT=true
NODERED_LOG_METRICS=true
```

## Git Workflow (Without Projects Feature)

This environment has Projects feature disabled by default (best for CI/CD). Use direct Git workflow:

### Initial Setup

```bash
cd $NODERED_DATA_DIR
git init
git add flows.json flows_cred.json package.json
git commit -m "Initial Node-RED flows"
git remote add origin https://github.com/yourorg/nodered-flows.git
git push -u origin main
```

### Deployment Workflow

```bash
# Development
# 1. Edit flows in interactive environment (nodered/)
# 2. Export flows
# 3. Commit to Git

# Production
git clone https://github.com/yourorg/nodered-flows.git flows
cp flows/*.json $NODERED_DATA_DIR/
flox services restart
```

### Automated Deployment

```bash
#!/bin/bash
# deploy-flows.sh

REPO="https://github.com/yourorg/nodered-flows.git"
BRANCH="main"

cd /tmp
git clone --depth 1 --branch $BRANCH $REPO nodered-flows
cp nodered-flows/flows.json $NODERED_DATA_DIR/
cp nodered-flows/flows_cred.json $NODERED_DATA_DIR/

flox services restart
```

## High Availability Patterns

### Load-Balanced Deployment

```
┌─────────────┐
│   HAProxy   │ ← Public traffic
└─────────────┘
      │
      ├─────────────────┐
      │                 │
┌───────────┐    ┌───────────┐
│ Node-RED  │    │ Node-RED  │
│ Instance  │    │ Instance  │
└───────────┘    └───────────┘
      │                 │
      └────────┬────────┘
               │
        ┌─────────────┐
        │    Redis    │ ← Shared context
        └─────────────┘
```

**Configuration**:
```bash
# Both instances
NODERED_CONTEXT_STORAGE=redis
REDIS_HOST=redis.ha.local
REDIS_PORT=6379
```

### Active-Passive Failover

```
┌─────────────┐
│   Primary   │ ← Active
│  Node-RED   │
└─────────────┘
      │
┌─────────────┐
│  Secondary  │ ← Standby
│  Node-RED   │
└─────────────┘
      │
┌─────────────┐
│    Redis    │ ← Shared state
└─────────────┘
```

**Healthcheck**: Monitor `/` endpoint

## Environment Variable Reference

### Complete List (25+ variables)

#### Core (3)
- `NODERED_PORT` (default: 1880)
- `NODERED_HOST` (default: 0.0.0.0)
- `NODERED_FLOW_FILE` (default: flows.json)

#### Security (7)
- `NODERED_ADMIN_AUTH_ENABLED` (default: true)
- `NODERED_ADMIN_USER` (default: admin)
- `NODERED_ADMIN_PASSWORD` (default: admin)
- `NODERED_ADMIN_PASSWORD_HASH` (default: "")
- `NODERED_HTTP_AUTH_ENABLED` (default: false)
- `NODERED_HTTP_USER`, `NODERED_HTTP_PASSWORD`, `NODERED_HTTP_PASSWORD_HASH`
- `NODERED_EDITOR_DISABLED` (default: false)

#### Context Storage (6)
- `NODERED_CONTEXT_STORAGE` (default: memory)
- `REDIS_HOST` (default: 127.0.0.1)
- `REDIS_PORT` (default: 16379)
- `REDIS_DB` (default: 0)
- `REDIS_PASSWORD` (default: "")
- `REDIS_KEY_PREFIX` (default: nodered)

#### Projects (2)
- `NODERED_PROJECTS_ENABLED` (default: false)
- `NODERED_PROJECTS_WORKFLOW_MODE` (default: manual)

#### Logging (4)
- `NODERED_LOG_LEVEL` (default: info)
- `NODERED_LOG_AUDIT` (default: false)
- `NODERED_LOG_METRICS` (default: false)
- `NODERED_LOG_FILE_PATH`

#### Performance (3)
- `NODERED_API_MAX_LENGTH` (default: 5mb)
- `NODERED_FUNCTION_TIMEOUT` (default: 0)
- `NODERED_DEBUG_MAX_LENGTH` (default: 1000)

#### HTTPS (3)
- `NODERED_HTTPS_ENABLED` (default: false)
- `NODERED_HTTPS_KEY_PATH`
- `NODERED_HTTPS_CERT_PATH`

#### Other (3)
- `NODERED_DASHBOARD_PATH` (default: /ui)
- `NODERED_INSTALL_NODES` (default: @flowfuse/node-red-dashboard)
- `NODERED_CREDENTIAL_SECRET` (auto-generated)

## Composed Environments

This environment includes:
- **redis** - Redis 7.x server (used for context storage if configured)

## Related Environments

- **nodered-local** - Interactive environment with configuration wizard
- **redis** / **redis-local** - Redis cache/queue
- **n8n** / **n8n-local** - Alternative workflow automation (cloud SaaS focused)

## Resources

- [Node-RED Documentation](https://nodered.org/docs/)
- [Node-RED Admin API](https://nodered.org/docs/api/admin/)
- [Node-RED Settings File](https://nodered.org/docs/user-guide/runtime/settings-file)
- [Node-RED Environment Variables](https://nodered.org/docs/getting-started/docker#environment-variables)
- [Node-RED Forum](https://discourse.nodered.org/)
- [Node-RED GitHub](https://github.com/node-red/node-red)

## Support

For issues with this Flox environment:
- Check the main README at the repository root
- Review the manifest: `.flox/env/manifest.toml`
- Run `nodered-info` to inspect configuration

For Node-RED-specific issues:
- [Node-RED Documentation](https://nodered.org/docs/)
- [Node-RED Forum](https://discourse.nodered.org/)
