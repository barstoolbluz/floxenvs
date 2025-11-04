# n8n Workflow Automation - Interactive Environment

A fully-featured n8n workflow automation environment with an interactive configuration wizard. Includes PostgreSQL and Redis support for both regular and queue execution modes.

## Features

- 🎯 **Interactive Configuration Wizard** - gum-based guided setup
- 🗄️ **Database Support** - PostgreSQL (recommended) or SQLite
- ⚡ **Queue Mode** - Distributed execution with Redis and workers
- 🔒 **Security First** - Persistent encryption key management, optional basic auth
- 🌐 **Webhook Support** - Configure tunnel URLs (ngrok, etc.)
- 🔄 **Mode Switching** - Runtime switching between regular and queue modes
- 📊 **Monitoring** - Service status, logs, and configuration inspection

## Quick Start

### 1. Activate the Environment

```bash
cd n8n
flox activate -s
```

The interactive wizard will guide you through:
- Database selection (PostgreSQL/SQLite)
- Authentication configuration
- Webhook tunnel setup
- Queue mode and worker configuration
- Server host/port settings

### 2. Access n8n

Once services start, access the web UI:
```
http://localhost:5678
```

Default credentials (if basic auth enabled):
- Username: `admin`
- Password: `admin`

### 3. View Configuration

```bash
n8n-info
```

### 4. Reconfigure

```bash
n8n-reconfigure
```

Restarts services with new settings.

## Architecture

### Regular Mode (Default)
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

### Queue Mode (Distributed)
```
┌─────────────┐
│   n8n Main  │ ← UI + API only
│   Process   │
└─────────────┘
      │
      ↓
┌─────────────┐
│    Redis    │ ← Message queue
│   (Bull)    │
└─────────────┘
      │
      ↓
┌─────────────┐
│  n8n Worker │ ← Executes workflows
└─────────────┘
```

## Configuration Options

### Database

**PostgreSQL (Recommended)**:
```bash
# Uses composed postgres-headless environment
# Default connection:
Host: localhost
Port: 5432
Database: n8n
User: postgres
Password: postgres
```

**SQLite (Development)**:
```bash
# Stored in: $FLOX_ENV_CACHE/n8n-data/database.sqlite
# ⚠️  No official migration path to PostgreSQL
```

### Authentication

**Basic Auth (Default: Enabled)**:
```bash
Username: admin
Password: admin
```

**Disable Auth** (not recommended):
```bash
# Choose "No" when wizard asks about authentication
```

### Webhooks

For external webhook triggers, configure a tunnel URL:
```bash
# Example with ngrok:
ngrok http 5678

# Then enter the ngrok URL in the wizard:
https://abc123.ngrok.io
```

### Queue Mode

Enable distributed execution with Redis:
```bash
# Choose "Yes" when wizard asks about queue mode
# Configure number of workers (default: 2)
```

**Worker Concurrency**: Each worker handles 10 concurrent tasks by default.

## Runtime Configuration

### Override Defaults

Use environment variables before activation:

```bash
# Custom database
DB_POSTGRESDB_HOST=db.example.com \
DB_POSTGRESDB_PORT=5432 \
DB_POSTGRESDB_DATABASE=n8n_prod \
DB_POSTGRESDB_USER=n8n_user \
DB_POSTGRESDB_PASSWORD=secure_pass \
flox activate -s

# Custom server settings
N8N_HOST=n8n.example.com \
N8N_PORT=8080 \
N8N_PROTOCOL=https \
flox activate -s

# Queue mode with custom workers
EXECUTIONS_MODE=queue \
QUEUE_WORKERS=4 \
EXECUTIONS_WORKER_CONCURRENCY=20 \
flox activate -s
```

### Key Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `EXECUTIONS_MODE` | `regular` | Execution mode (`regular` or `queue`) |
| `N8N_HOST` | `localhost` | Server hostname |
| `N8N_PORT` | `5678` | Server port |
| `N8N_BASIC_AUTH_ACTIVE` | `true` | Enable basic authentication |
| `DB_TYPE` | `postgresdb` | Database type |
| `WEBHOOK_URL` | - | External webhook URL |
| `N8N_LOG_LEVEL` | `info` | Logging level |

## Commands

### Configuration

```bash
n8n-info             # Show current configuration
n8n-reconfigure      # Run wizard again and restart services
```

### Service Management

```bash
flox services status              # Check all services
flox services logs n8n-main       # View main process logs
flox services logs n8n-worker     # View worker logs (queue mode)
flox services restart             # Restart all services
flox services stop                # Stop all services
```

### Direct n8n Commands

```bash
n8n start            # Start n8n (manual)
n8n worker           # Start worker (manual, queue mode)
n8n import:workflow  # Import workflow from file
n8n import:credentials # Import credentials from file
n8n execute          # Execute workflow from CLI
```

## Directory Structure

```
$FLOX_ENV_CACHE/
├── n8n-config/              # Configuration files
├── n8n-data/                # User data, workflows, credentials
├── n8n-logs/                # Log files
└── n8n-encryption.key       # 🔒 CRITICAL: Backup this file!
```

## Security Considerations

### Encryption Key

**CRITICAL**: The encryption key is used to encrypt/decrypt all stored credentials in workflows.

- Location: `$FLOX_ENV_CACHE/n8n-encryption.key`
- **Without this key, stored credentials are UNRECOVERABLE**
- Back up this file immediately after first activation
- Store backup securely (password manager, encrypted vault)

### Authentication

**Production deployments should**:
- Enable basic authentication (or disable entirely if using external auth)
- Use HTTPS (`N8N_PROTOCOL=https`)
- Use strong passwords
- Configure webhook URLs with authentication tokens

### Database Security

**PostgreSQL defaults** (change for production):
```bash
DB_POSTGRESDB_PASSWORD=postgres  # ⚠️  Change this!
```

### Redis Security (Queue Mode)

**Redis defaults** (change for production):
```bash
QUEUE_BULL_REDIS_PASSWORD=""  # ⚠️  Set a password!
```

## Use Cases

### Local Development
```bash
# Default wizard settings work great
flox activate -s
```

### Production Deployment
```bash
# Custom everything
DB_POSTGRESDB_HOST=prod-db.example.com \
DB_POSTGRESDB_PASSWORD="$(cat /secrets/db-password)" \
N8N_BASIC_AUTH_PASSWORD="$(cat /secrets/admin-password)" \
WEBHOOK_URL=https://n8n.example.com \
EXECUTIONS_MODE=queue \
QUEUE_WORKERS=4 \
flox activate -s
```

### CI/CD Integration
```bash
# Headless testing (use n8n-headless environment instead)
N8N_DISABLE_UI=true \
N8N_LOG_OUTPUT=file \
flox activate
```

## Troubleshooting

### Services Not Starting

```bash
# Check service status
flox services status

# Check logs
flox services logs n8n-main

# Verify PostgreSQL is running
flox services logs postgres
```

### Cannot Connect to Database

```bash
# Verify PostgreSQL connection
echo "SELECT version();" | psql -h localhost -p 5432 -U postgres

# Check database exists
echo "SELECT datname FROM pg_database;" | psql -h localhost -p 5432 -U postgres
```

### Cannot Connect to Redis (Queue Mode)

```bash
# Verify Redis is running
redis-cli -h 127.0.0.1 -p 16379 PING

# Should return: PONG
```

### Webhooks Not Working

1. Verify webhook URL is accessible from external internet
2. Check webhook URL matches n8n's webhook URL setting
3. Test with `curl` from external host

### Encryption Key Issues

**If you lose the encryption key**:
- Stored credentials in workflows become unrecoverable
- You must manually re-enter all credentials
- Workflows will fail until credentials are restored

**If you need to reset**:
```bash
# Stop services
flox services stop

# Remove old key
rm $FLOX_ENV_CACHE/n8n-encryption.key

# Reactivate (new key will be generated)
flox activate -s

# ⚠️  All stored credentials must be re-entered!
```

## Composed Environments

This environment includes:
- **postgres-headless** - PostgreSQL database server
- **redis-headless** - Redis message queue (for queue mode)

## Related Environments

- **n8n-headless** - Headless automation environment with 4 pre-configured workers
- **postgres** / **postgres-headless** - PostgreSQL database
- **redis** / **redis-headless** - Redis cache/queue

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n Workflow Templates](https://n8n.io/workflows/)
- [n8n GitHub](https://github.com/n8n-io/n8n)

## Support

For issues with this Flox environment:
- Check the main README at the repository root
- Review the manifest: `.flox/env/manifest.toml`

For n8n-specific issues:
- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
