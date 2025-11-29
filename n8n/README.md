# n8n Workflow Automation - Headless Environment

Production-ready n8n environment with zero interaction, configured entirely via environment variables. Pre-configured with 4 workers for distributed queue execution, PostgreSQL, and Redis.

## Features

- 🚀 **Zero Interaction** - Configure entirely via environment variables
- 🔄 **Pre-configured Workers** - 4 workers ready for queue mode
- 🗄️ **PostgreSQL Database** - Production-ready persistent storage
- ⚡ **Redis Queue** - Bull queue for distributed execution
- 🔒 **Security First** - Persistent encryption key, authentication controls
- 📊 **40+ Environment Variables** - Complete runtime configurability
- 🎯 **CI/CD Ready** - Designed for automation and orchestration

## Quick Start

### Regular Mode (Single Process)

```bash
cd n8n
flox activate -s
```

Access n8n at `http://localhost:5678` with credentials:
- Username: `admin`
- Password: `admin`

### Queue Mode (Distributed Execution)

```bash
cd n8n
EXECUTIONS_MODE=queue flox activate -s
```

This starts:
- Main process (UI + API)
- 4 worker processes (execution)
- Redis (message queue)
- PostgreSQL (database)

## Architecture

### Regular Mode
```
┌─────────────┐
│   n8n Main  │ ← Single process: UI + execution
│   Process   │
└─────────────┘
      │
      ↓
┌─────────────┐
│ PostgreSQL  │
└─────────────┘
```

### Queue Mode
```
┌─────────────┐
│   n8n Main  │ ← UI + API
│   Process   │
└─────────────┘
      │
      ↓
┌─────────────┐     ┌──────────────┐
│    Redis    │ ←───│  n8n Worker  │ ← 4x Workers
│   (Bull)    │     │  Processes   │   (pre-configured)
└─────────────┘     └──────────────┘
      │
      ↓
┌─────────────┐
│ PostgreSQL  │
└─────────────┘
```

## Configuration

### Database Configuration

```bash
# PostgreSQL (default)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=postgres
DB_POSTGRESDB_PASSWORD=postgres
DB_POSTGRESDB_SCHEMA=public

# Connection pool
DB_POSTGRESDB_POOL_SIZE=2
DB_POSTGRESDB_SSL_ENABLED=false
DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=true
```

### Execution Mode

```bash
# Regular mode (default) - single process
EXECUTIONS_MODE=regular

# Queue mode - distributed with workers
EXECUTIONS_MODE=queue
```

### Queue Configuration (Redis)

```bash
# Redis connection
QUEUE_BULL_REDIS_HOST=127.0.0.1
QUEUE_BULL_REDIS_PORT=16379
QUEUE_BULL_REDIS_DB=0
QUEUE_BULL_REDIS_PASSWORD=""
QUEUE_BULL_REDIS_TIMEOUT_THRESHOLD=10000

# Health checks
QUEUE_HEALTH_CHECK_ACTIVE=true

# Worker concurrency (per worker)
EXECUTIONS_WORKER_CONCURRENCY=10
```

### Server Configuration

```bash
# Network settings
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_LISTEN_ADDRESS=0.0.0.0
```

### Authentication

```bash
# Basic authentication (enabled by default)
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=admin

# Disable authentication (not recommended)
N8N_BASIC_AUTH_ACTIVE=false
```

### Encryption Key

**CRITICAL**: The encryption key encrypts all stored credentials.

```bash
# Automatic generation (default)
# Key stored in: $FLOX_ENV_CACHE/n8n-encryption.key

# Override with custom key
N8N_ENCRYPTION_KEY=your-64-character-hex-key

# ⚠️  Without this key, stored credentials are UNRECOVERABLE
```

### Webhooks

```bash
# External webhook URL (for external triggers)
WEBHOOK_URL=https://n8n.example.com

# Or tunnel URL (ngrok, etc.)
WEBHOOK_TUNNEL_URL=https://abc123.ngrok.io
```

### Paths

```bash
# n8n data directory
N8N_USER_FOLDER=$N8N_DATA_DIR  # Default: $FLOX_ENV_CACHE/n8n-data

# Custom extensions
N8N_CUSTOM_EXTENSIONS=/path/to/extensions
```

### Execution Settings

```bash
# Save execution data
EXECUTIONS_DATA_SAVE_ON_ERROR=all
EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
EXECUTIONS_DATA_SAVE_ON_PROGRESS=false
EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true

# Execution pruning
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=336  # hours (14 days)
EXECUTIONS_DATA_PRUNE_MAX_COUNT=10000
```

### Workflow Settings

```bash
# Default workflow name
WORKFLOWS_DEFAULT_NAME="My Workflow"

# Workflow caller policy
WORKFLOW_CALLER_POLICY_DEFAULT_OPTION=workflowsFromSameOwner
```

### Timeout Settings

```bash
# Execution timeout (empty = no timeout)
EXECUTIONS_TIMEOUT=""

# Maximum timeout (seconds)
EXECUTIONS_TIMEOUT_MAX=3600
```

### Logging

```bash
# Log level
N8N_LOG_LEVEL=info  # Options: error, warn, info, verbose, debug

# Log output
N8N_LOG_OUTPUT=console  # Options: console, file

# Log file location
N8N_LOG_FILE_LOCATION=$N8N_LOG_DIR/n8n.log
```

### Editor & UI

```bash
# Editor base URL
N8N_EDITOR_BASE_URL=""

# Disable UI (headless mode)
N8N_DISABLE_UI=false
```

### Security

```bash
# Secure cookies (HTTPS only)
N8N_SECURE_COOKIE=""

# Feature flags
N8N_PERSONALIZATION_ENABLED=true
N8N_VERSION_NOTIFICATIONS_ENABLED=true
N8N_DIAGNOSTICS_ENABLED=true
N8N_HIRING_BANNER_ENABLED=true
```

### SMTP (Email Notifications)

```bash
N8N_SMTP_HOST=""
N8N_SMTP_PORT=465
N8N_SMTP_USER=""
N8N_SMTP_PASS=""
N8N_SMTP_SENDER=""
N8N_SMTP_SSL=true
```

### Nodes

```bash
# Exclude specific nodes
NODES_EXCLUDE=""

# Include only specific nodes
NODES_INCLUDE=""

# Function node permissions
NODE_FUNCTION_ALLOW_BUILTIN=""
NODE_FUNCTION_ALLOW_EXTERNAL=""
```

### Timezone

```bash
GENERIC_TIMEZONE=America/New_York
TZ=$GENERIC_TIMEZONE
```

## Usage Examples

### Local Development

```bash
# Default settings (PostgreSQL, regular mode)
flox activate -s
```

### Production Queue Mode

```bash
# 4 workers, custom database, authentication
DB_POSTGRESDB_HOST=prod-db.example.com \
DB_POSTGRESDB_DATABASE=n8n_prod \
DB_POSTGRESDB_PASSWORD=secure_password \
N8N_BASIC_AUTH_PASSWORD=admin_password \
EXECUTIONS_MODE=queue \
EXECUTIONS_WORKER_CONCURRENCY=20 \
WEBHOOK_URL=https://n8n.example.com \
flox activate -s
```

### High-Concurrency Setup

```bash
# Each worker handles 20 concurrent tasks = 80 total
EXECUTIONS_MODE=queue \
EXECUTIONS_WORKER_CONCURRENCY=20 \
flox activate -s
```

### Secure Production Deployment

```bash
# HTTPS, strong auth, secure Redis
N8N_PROTOCOL=https \
N8N_HOST=n8n.example.com \
N8N_PORT=443 \
N8N_BASIC_AUTH_PASSWORD="$(cat /secrets/admin-pass)" \
DB_POSTGRESDB_PASSWORD="$(cat /secrets/db-pass)" \
QUEUE_BULL_REDIS_PASSWORD="$(cat /secrets/redis-pass)" \
EXECUTIONS_MODE=queue \
flox activate -s
```

### CI/CD Testing

```bash
# Headless, file logging, no UI
N8N_DISABLE_UI=true \
N8N_LOG_OUTPUT=file \
N8N_LOG_LEVEL=debug \
flox activate
```

## Commands

### Configuration Inspection

```bash
n8n-info  # Show complete configuration
```

### Service Management

```bash
flox services status              # Check service status
flox services logs n8n-main       # Main process logs
flox services logs n8n-worker-1   # Worker 1 logs
flox services logs n8n-worker-2   # Worker 2 logs
flox services logs n8n-worker-3   # Worker 3 logs
flox services logs n8n-worker-4   # Worker 4 logs
flox services restart             # Restart all services
```

### Direct n8n Commands

```bash
n8n start                  # Start main process
n8n worker                 # Start worker
n8n import:workflow        # Import workflow
n8n import:credentials     # Import credentials
n8n execute                # Execute workflow from CLI
n8n export:workflow        # Export workflows
n8n export:credentials     # Export credentials
```

## Workers

### Pre-configured Workers

This environment includes **4 pre-configured workers**:
- `n8n-worker-1`
- `n8n-worker-2`
- `n8n-worker-3`
- `n8n-worker-4`

### Worker Behavior

**Regular Mode** (`EXECUTIONS_MODE=regular`):
- Workers remain idle (`tail -f /dev/null`)
- Main process handles all execution
- No Redis connection required

**Queue Mode** (`EXECUTIONS_MODE=queue`):
- All 4 workers start automatically
- Each worker connects to Redis
- Each worker handles `EXECUTIONS_WORKER_CONCURRENCY` concurrent tasks

### Concurrency Calculation

```bash
# Default: 10 tasks per worker × 4 workers = 40 concurrent tasks
EXECUTIONS_WORKER_CONCURRENCY=10

# High concurrency: 20 tasks per worker × 4 workers = 80 concurrent tasks
EXECUTIONS_WORKER_CONCURRENCY=20
```

### Scaling Workers

To change the number of workers, edit `.flox/env/manifest.toml`:

```toml
# Add worker 5
[services]
n8n-worker-5.command = '''
if [ "$EXECUTIONS_MODE" = "queue" ]; then
    exec n8n worker --concurrency="$EXECUTIONS_WORKER_CONCURRENCY"
else
    tail -f /dev/null
fi
'''
```

Then restart:
```bash
flox services restart
```

## Directory Structure

```
$FLOX_ENV_CACHE/
├── n8n-config/              # Configuration files
├── n8n-data/                # User data, workflows, credentials
├── n8n-logs/                # Log files
│   └── n8n.log             # Main log file
└── n8n-encryption.key       # 🔒 CRITICAL: Backup this file!
```

## Security Best Practices

### 1. Encryption Key Backup

```bash
# Location
$FLOX_ENV_CACHE/n8n-encryption.key

# Backup immediately after first activation
cp $FLOX_ENV_CACHE/n8n-encryption.key ~/backups/n8n-encryption.key.backup

# Store securely (password manager, encrypted vault)
```

**Without this key, ALL stored credentials are UNRECOVERABLE.**

### 2. Change Default Passwords

```bash
# Database
DB_POSTGRESDB_PASSWORD=your-secure-db-password

# n8n Admin
N8N_BASIC_AUTH_PASSWORD=your-secure-admin-password

# Redis (queue mode)
QUEUE_BULL_REDIS_PASSWORD=your-secure-redis-password
```

### 3. Use HTTPS in Production

```bash
N8N_PROTOCOL=https
N8N_SECURE_COOKIE=true
```

### 4. Network Security

```bash
# Only bind to localhost if behind reverse proxy
N8N_LISTEN_ADDRESS=127.0.0.1

# Or bind to all interfaces if direct access
N8N_LISTEN_ADDRESS=0.0.0.0
```

### 5. Webhook Security

Include authentication tokens in webhook URLs:
```bash
WEBHOOK_URL=https://n8n.example.com/webhook/abc123token
```

## Monitoring & Troubleshooting

### Check Service Status

```bash
flox services status
```

Expected output:
```
n8n-main      [RUNNING]
n8n-worker-1  [RUNNING]  # Only in queue mode
n8n-worker-2  [RUNNING]  # Only in queue mode
n8n-worker-3  [RUNNING]  # Only in queue mode
n8n-worker-4  [RUNNING]  # Only in queue mode
postgres      [RUNNING]
redis         [RUNNING]
```

### View Logs

```bash
# All logs
flox services logs

# Specific service
flox services logs n8n-main

# Follow logs (live)
flox services logs n8n-main -f
```

### Database Connection Issues

```bash
# Test PostgreSQL connection
echo "SELECT version();" | psql -h $DB_POSTGRESDB_HOST -p $DB_POSTGRESDB_PORT -U $DB_POSTGRESDB_USER

# List databases
echo "SELECT datname FROM pg_database;" | psql -h $DB_POSTGRESDB_HOST -p $DB_POSTGRESDB_PORT -U $DB_POSTGRESDB_USER
```

### Redis Connection Issues (Queue Mode)

```bash
# Test Redis connection
redis-cli -h $QUEUE_BULL_REDIS_HOST -p $QUEUE_BULL_REDIS_PORT PING

# Check queue statistics
redis-cli -h $QUEUE_BULL_REDIS_HOST -p $QUEUE_BULL_REDIS_PORT INFO
```

### Worker Not Processing

Check worker logs:
```bash
flox services logs n8n-worker-1
flox services logs n8n-worker-2
flox services logs n8n-worker-3
flox services logs n8n-worker-4
```

Common issues:
- Redis not running
- `EXECUTIONS_MODE` not set to `queue`
- Redis connection parameters incorrect

### Performance Tuning

```bash
# Increase worker concurrency
EXECUTIONS_WORKER_CONCURRENCY=20

# Increase database pool size
DB_POSTGRESDB_POOL_SIZE=10

# Increase execution timeout
EXECUTIONS_TIMEOUT_MAX=7200  # 2 hours
```

## Composed Environments

This environment includes:
- **postgres** - PostgreSQL 17.x database server
- **redis** - Redis 7.x message queue

## Migrating from n8n (Interactive)

Both environments use the same `$FLOX_ENV_CACHE` structure:

```bash
# They share the same encryption key
$FLOX_ENV_CACHE/n8n-encryption.key

# Same data directory
$FLOX_ENV_CACHE/n8n-data/

# Same configuration
$FLOX_ENV_CACHE/n8n-config/
```

**To migrate**:
1. Ensure encryption key is backed up
2. Export workflows from interactive environment
3. Activate this environment with same `FLOX_ENV_CACHE`
4. Import workflows

## Environment Variables Reference

### Critical Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `EXECUTIONS_MODE` | `regular` | `regular` or `queue` |
| `N8N_ENCRYPTION_KEY` | auto-generated | 64-char hex key |
| `N8N_BASIC_AUTH_PASSWORD` | `admin` | Admin password |
| `DB_POSTGRESDB_PASSWORD` | `postgres` | Database password |

### All Variables

See [Configuration](#configuration) section above for complete list of 40+ environment variables.

## Related Environments

- **n8n-local** - Interactive environment with configuration wizard
- **postgres** / **postgres-local** - PostgreSQL database
- **redis** / **redis-local** - Redis cache/queue

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Queue Mode Docs](https://docs.n8n.io/hosting/scaling/queue-mode/)
- [n8n Environment Variables](https://docs.n8n.io/hosting/configuration/environment-variables/)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n GitHub](https://github.com/n8n-io/n8n)

## Support

For issues with this Flox environment:
- Check the main README at the repository root
- Review the manifest: `.flox/env/manifest.toml`
- Run `n8n-info` to inspect configuration

For n8n-specific issues:
- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
