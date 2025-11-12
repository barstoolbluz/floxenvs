# Prefect (Headless Mode)

Prefect orchestration platform with optional PostgreSQL support via composition. Headless mode for automation, CI/CD, and production deployments.

## Features

- ✅ **Prefect 3.5.0** complete platform (server, worker, REST API)
- ✅ **SQLite storage** (default) - fast local development
- ✅ **PostgreSQL support** (optional) - production-ready via composition
- ✅ **Auto-configuration** - smart detection and connection URL generation
- ✅ **Zero interaction** - all configuration via environment variables
- ✅ **Container-friendly** - no TTY required, perfect for Docker/K8s
- ✅ **Remote access** - configurable for network/browser access

## Quick Start

### Default (SQLite)
```bash
flox activate -s
# Prefect running with SQLite at http://127.0.0.1:4200
```

### With PostgreSQL
```bash
PREFECT_STORAGE_TYPE=postgres PGDATABASE=prefect flox activate -s
# Prefect running with PostgreSQL at http://127.0.0.1:4200
```

### Remote Access
```bash
# For accessing UI from other machines on your network
PREFECT_UI_API_URL=http://your-hostname:4200/api flox activate -s
```

## Configuration

### Core Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `PREFECT_HOME` | `$FLOX_ENV_CACHE/prefect-data` | Instance metadata directory |
| `PREFECT_SERVER_HOST` | `0.0.0.0` | Server bind address (all interfaces) |
| `PREFECT_SERVER_PORT` | `4200` | Server port |

### Client Connection

| Variable | Default | Description |
|----------|---------|-------------|
| `PREFECT_API_HOST` | `127.0.0.1` | Client connection address for CLI/workers |
| `PREFECT_API_URL` | (auto) | Full API endpoint (auto-generated) |
| `PREFECT_UI_API_URL` | (auto) | URL for browser UI to reach API (important for remote access!) |

### Storage Backend

| Variable | Default | Description |
|----------|---------|-------------|
| `PREFECT_STORAGE_TYPE` | `sqlite` | Storage type (`sqlite` or `postgres`) |
| `PREFECT_DATABASE_URL` | (auto) | PostgreSQL connection URL (auto-generated if not provided) |

### Worker Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `PREFECT_WORKER_POOL_NAME` | `default-pool` | Worker pool name |
| `PREFECT_WORKER_LIMIT` | `10` | Max concurrent flow runs per worker |
| `PREFECT_WORKER_QUERY_SECONDS` | `5` | Polling interval (seconds) |

### Logging

| Variable | Default | Description |
|----------|---------|-------------|
| `PREFECT_LOGGING_LEVEL` | `INFO` | Logging level |
| `PREFECT_LOGGING_TO_API_ENABLED` | `true` | Send logs to API |

### Control Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `PREFECT_SKIP_INIT` | - | Set to `1` to skip database initialization |
| `PREFECT_QUIET` | - | Set to `1` to suppress welcome message |
| `PREFECT_EPHEMERAL` | - | Set to `1` for ephemeral mode (no server required) |

## Usage Examples

### Local Development (SQLite)
```bash
flox activate -s
```

### Production (PostgreSQL - Auto-configured)
```bash
# PostgreSQL variables from composed postgres-headless environment
PREFECT_STORAGE_TYPE=postgres \
PGDATABASE=prefect \
flox activate -s
```

### Production (PostgreSQL - Custom Server)
```bash
PREFECT_STORAGE_TYPE=postgres \
PREFECT_DATABASE_URL="postgresql+asyncpg://user:pass@prod-db:5432/prefect" \
flox activate -s
```

### Remote Access Setup

**On the server:**
```bash
# Set UI API URL to your server's hostname or IP
PREFECT_UI_API_URL=http://myserver.example.com:4200/api flox activate -s
```

**Access from browser:**
```
http://myserver.example.com:4200
```

The UI will now correctly connect to the API using the hostname instead of localhost.

### CI/CD Pipeline
```bash
# Dockerfile example
FROM ubuntu:22.04
RUN curl -fsSL https://get.flox.dev | bash
COPY . /app
WORKDIR /app
ENV PREFECT_STORAGE_TYPE=postgres
ENV PREFECT_DATABASE_URL="postgresql+asyncpg://user:pass@postgres:5432/prefect"
ENV PREFECT_SERVER_HOST=0.0.0.0
ENV PREFECT_UI_API_URL="http://prefect-service:4200/api"
CMD ["flox", "activate", "-s"]
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prefect
spec:
  template:
    spec:
      containers:
      - name: prefect-server
        image: your-flox-image
        env:
        - name: PREFECT_STORAGE_TYPE
          value: "postgres"
        - name: PREFECT_DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: prefect-db
              key: connection-url
        - name: PREFECT_SERVER_HOST
          value: "0.0.0.0"
        - name: PREFECT_UI_API_URL
          value: "https://prefect.company.com/api"
        ports:
        - containerPort: 4200
        command: ["flox", "activate", "--", "flox", "services", "start", "prefect-server"]
```

### Reverse Proxy Setup (Nginx)
```nginx
server {
    listen 443 ssl;
    server_name prefect.company.com;

    location / {
        proxy_pass http://localhost:4200;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

With environment:
```bash
PREFECT_UI_API_URL=https://prefect.company.com/api flox activate -s
```

## PostgreSQL Composition

This environment includes `barstoolbluz/postgres-headless` for optional PostgreSQL support.

**How it works:**
1. When `PREFECT_STORAGE_TYPE=postgres`, Prefect auto-detects the composed PostgreSQL environment
2. Connection URL is auto-generated from postgres environment variables:
   - `PGUSER` (default: `pguser`)
   - `PGPASSWORD` (default: `pgpass`)
   - `PGHOSTADDR` (default: `127.0.0.1`)
   - `PGPORT` (default: `15432`)
   - `PGDATABASE` (set to `prefect` for dedicated DB)
3. If postgres not available, gracefully falls back to SQLite

**Manual postgres service control:**
```bash
# Activate with postgres configured
PREFECT_STORAGE_TYPE=postgres PGDATABASE=prefect flox activate

# Start postgres service
flox services start postgres

# Start prefect services
flox services start prefect-server
flox services start prefect-worker
```

## Commands

### Service Management
```bash
flox services status                    # Check all services
flox services logs prefect-server       # View server logs
flox services logs prefect-worker       # View worker logs
flox services logs postgres             # View postgres logs (if using)
```

### Prefect CLI
```bash
prefect --version                       # Show Prefect version
prefect server database check           # Check database connection
prefect-info                            # Show configuration
prefect work-pool ls                    # List work pools
prefect deployment ls                   # List deployments
prefect flow-run ls                     # List flow runs
```

### Running Example Flows
```bash
# Ephemeral mode (no server required)
PREFECT_EPHEMERAL=1 flox activate -- python $PREFECT_FLOWS_DIR/hello_flow.py

# With server running
flox activate -- python $PREFECT_FLOWS_DIR/data_pipeline.py
```

## Services

This environment provides two services:

- **prefect-server** - Web UI and REST API (port 4200)
- **prefect-worker** - Background worker for flow execution

When PostgreSQL composition is used, the `postgres` service is also available.

## Files & Directories

```
$PREFECT_HOME/
├── prefect.db                # SQLite database (SQLite mode)
├── logs/                     # Flow run logs
└── ui/                       # UI static files (Nix-safe location)

$PREFECT_FLOWS_DIR/           # Example flow definitions
├── hello_flow.py
├── data_pipeline.py
└── scheduled_flow.py

$PREFECT_STORAGE_DIR/         # Artifact and result storage
```

## Architecture

**SQLite Mode (Default):**
```
prefect-server ─┐
                ├─> SQLite DB
prefect-worker ─┘
```

**PostgreSQL Mode (Composed):**
```
prefect-server ─┐
                ├─> PostgreSQL
prefect-worker ─┘
        │
        └─> postgres service (from composition)
```

## Remote Access Configuration

Understanding the three URL settings:

### 1. Server Bind Address (`PREFECT_SERVER_HOST`)
- **Where the server listens** (network interface)
- `0.0.0.0` = All interfaces (default) - accessible from network
- `127.0.0.1` = Localhost only - maximum security

### 2. Client API URL (`PREFECT_API_URL`)
- **Where CLI tools and workers connect**
- Default: `http://127.0.0.1:4200/api`
- Used by `prefect` commands and Python SDK

### 3. Browser UI API URL (`PREFECT_UI_API_URL`)
- **Where the browser's JavaScript connects**
- Default: Same as `PREFECT_API_URL`
- **Must be set for remote access!**

### Common Scenarios

**Local development (default):**
```bash
# No configuration needed
flox activate -s
# Access: http://localhost:4200
```

**Access from network (same machine name on all clients):**
```bash
# On server
PREFECT_UI_API_URL=http://myserver:4200/api flox activate -s
# Clients access: http://myserver:4200
```

**Access from network (IP address):**
```bash
# On server
PREFECT_UI_API_URL=http://192.168.1.100:4200/api flox activate -s
# Clients access: http://192.168.1.100:4200
```

**Behind reverse proxy with SSL:**
```bash
# On server (behind proxy)
PREFECT_UI_API_URL=https://prefect.company.com/api flox activate -s
# Users access: https://prefect.company.com
```

**Using .env file (recommended):**
```bash
# Create .env in environment directory
cat > .env << EOF
PREFECT_UI_API_URL=http://myserver:4200/api
PREFECT_STORAGE_TYPE=postgres
PGDATABASE=prefect
EOF

# Prefect automatically loads .env on startup
flox activate -s
```

## Troubleshooting

### Services won't start
```bash
# Check service status
flox services status

# View logs
flox services logs prefect-server
flox services logs prefect-worker

# Check port availability
netstat -tuln | grep 4200

# Restart services
flox services restart prefect-server
```

### PostgreSQL connection issues
```bash
# Verify postgres is running
flox services status postgres

# Check connection URL
echo $PREFECT_DATABASE_URL

# Test postgres connectivity
pg_isready -h $PGHOSTADDR -p $PGPORT

# Verify database exists
psql -l
```

### UI can't connect to API (remote access)
```bash
# Check what UI is configured to use
echo $PREFECT_UI_API_URL

# Should be your server's hostname/IP, not 127.0.0.1
# Set it correctly:
PREFECT_UI_API_URL=http://your-server:4200/api flox activate -s
```

### Worker not picking up flows
```bash
# Check worker pool exists
prefect work-pool ls

# Check worker is running
flox services status prefect-worker
flox services logs prefect-worker

# Check deployments
prefect deployment ls
```

### Permission denied: ui_build
This is fixed in the environment. If you see this error:
```bash
# The PREFECT_SERVER_UI_STATIC_DIRECTORY is automatically set
# to $PREFECT_HOME/ui to avoid Nix store write issues
echo $PREFECT_SERVER_UI_STATIC_DIRECTORY
```

## Composition

This environment can be included in other Flox environments:

```toml
# In your manifest.toml
[include]
environments = [
  { remote = "barstoolbluz/prefect-headless" }
]
```

All prefect commands and services become available in your composed environment.

## Use Cases

- **CI/CD Pipelines** - Automated workflow testing and deployment
- **Docker Containers** - Containerized Prefect deployments
- **Kubernetes** - K8s-native workflow orchestration
- **Production Deployments** - Production-grade orchestration
- **Multi-tenant** - Multiple isolated Prefect instances
- **Development** - Fast local development with SQLite
- **Remote Teams** - Network-accessible UI for team collaboration

## Production Considerations

**Security:**
- Use `PREFECT_UI_API_URL` with proper hostname for remote access
- Deploy behind reverse proxy for SSL/TLS
- Use PostgreSQL for production (SQLite not suitable for concurrent access)
- Secure postgres connection strings via secrets management
- Never expose server on 0.0.0.0 without firewall/proxy

**Performance:**
- Adjust `PREFECT_WORKER_LIMIT` based on available resources
- Use PostgreSQL with connection pooling for high-throughput workloads
- Monitor worker logs for flow execution delays
- Consider multiple workers for scale

**High Availability:**
- Run multiple `prefect-server` instances behind a load balancer
- Run multiple workers for redundancy and scale
- Use PostgreSQL with replication for storage backend
- Deploy on Kubernetes with appropriate resource limits and probes

**Monitoring:**
- Health check endpoint: `/api/health`
- Monitor worker process health
- Track flow run queue depth via UI
- Set up alerts for failed runs

## Links

- [Prefect Documentation](https://docs.prefect.io/)
- [Prefect GitHub](https://github.com/PrefectHQ/prefect)
- [Settings Reference](https://docs.prefect.io/v3/api-ref/settings-ref)
- [Kubernetes Deployment](https://docs.prefect.io/latest/guides/deployment/kubernetes/)
- [Self-Hosting Guide](https://docs-3.prefect.io/3.0/manage/self-host)

---

**Version:** Prefect 3.5.0 with PostgreSQL support
**FloxHub:** `barstoolbluz/prefect-headless`
