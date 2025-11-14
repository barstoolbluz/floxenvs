# Temporal (Headless Mode)

Temporal orchestration platform with optional PostgreSQL support via composition. Headless mode for automation, CI/CD, and production deployments.

## Features

- ✅ **Temporal 1.29.1** complete platform (frontend, history, matching, worker services)
- ✅ **SQLite storage** (default) - fast local development
- ✅ **PostgreSQL support** (optional) - production-ready via composition
- ✅ **Auto-configuration** - smart detection and connection URL generation
- ✅ **Zero interaction** - all configuration via environment variables
- ✅ **Container-friendly** - no TTY required, perfect for Docker/K8s
- ✅ **Remote access** - configurable for network access

## Quick Start

### Default (SQLite)
```bash
flox activate -s
# Temporal running with SQLite at localhost:7233
```

### With PostgreSQL
```bash
TEMPORAL_STORAGE_TYPE=postgres PGDATABASE=temporal flox activate -s
# Temporal running with PostgreSQL at localhost:7233
```

## Configuration

### Core Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `TEMPORAL_HOME` | `$FLOX_ENV_CACHE/temporal-data` | Instance metadata directory |
| `TEMPORAL_FRONTEND_HOST` | `127.0.0.1` | Frontend server bind address |
| `TEMPORAL_FRONTEND_PORT` | `7233` | Frontend gRPC port |
| `TEMPORAL_WEB_PORT` | `8233` | Web UI port |

### Storage Backend

| Variable | Default | Description |
|----------|---------|-------------|
| `TEMPORAL_STORAGE_TYPE` | `sqlite` | Storage type (`sqlite` or `postgres`) |
| `TEMPORAL_POSTGRES_URL` | (auto) | PostgreSQL connection URL (auto-generated if not provided) |

### Control Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `TEMPORAL_SKIP_INIT` | - | Set to `1` to skip initialization |
| `TEMPORAL_QUIET` | - | Set to `1` to suppress welcome message |

## Usage Examples

### Local Development (SQLite)
```bash
flox activate -s
```

### Production (PostgreSQL - Auto-configured)
```bash
# PostgreSQL variables from composed postgres-headless environment
TEMPORAL_STORAGE_TYPE=postgres \
PGDATABASE=temporal \
flox activate -s
```

### Production (PostgreSQL - Custom Server)
```bash
TEMPORAL_STORAGE_TYPE=postgres \
TEMPORAL_POSTGRES_URL="postgresql://user:pass@prod-db:5432/temporal" \
flox activate -s
```

### Remote Access Setup

**On the server:**
```bash
# Bind to all interfaces
TEMPORAL_FRONTEND_HOST=0.0.0.0 flox activate -s
```

**Access from clients:**
```bash
# Set Temporal frontend address in your code
temporal.Client.connect("myserver.example.com:7233")
```

### CI/CD Pipeline
```bash
# Dockerfile example
FROM ubuntu:22.04
RUN curl -fsSL https://get.flox.dev | bash
COPY . /app
WORKDIR /app
ENV TEMPORAL_STORAGE_TYPE=postgres
ENV TEMPORAL_POSTGRES_URL="postgresql://user:pass@postgres:5432/temporal"
ENV TEMPORAL_FRONTEND_HOST=0.0.0.0
CMD ["flox", "activate", "-s"]
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: temporal
spec:
  template:
    spec:
      containers:
      - name: temporal-server
        image: your-flox-image
        env:
        - name: TEMPORAL_STORAGE_TYPE
          value: "postgres"
        - name: TEMPORAL_POSTGRES_URL
          valueFrom:
            secretKeyRef:
              name: temporal-db
              key: connection-url
        - name: TEMPORAL_FRONTEND_HOST
          value: "0.0.0.0"
        ports:
        - containerPort: 7233
          name: frontend
        command: ["flox", "activate", "--", "flox", "services", "start", "temporal-server"]
```

### Reverse Proxy Setup (Nginx)
```nginx
upstream temporal_frontend {
    server localhost:7233;
}

server {
    listen 443 ssl http2;
    server_name temporal.company.com;

    location / {
        grpc_pass grpc://temporal_frontend;
        grpc_set_header Host $host;
    }
}
```

## PostgreSQL Composition

This environment includes `barstoolbluz/postgres-headless` for optional PostgreSQL support.

**How it works:**
1. When `TEMPORAL_STORAGE_TYPE=postgres`, Temporal auto-detects the composed PostgreSQL environment
2. Connection URL is auto-generated from postgres environment variables:
   - `PGUSER` (default: `pguser`)
   - `PGPASSWORD` (default: `pgpass`)
   - `PGHOSTADDR` (default: `127.0.0.1`)
   - `PGPORT` (default: `15432`)
   - `PGDATABASE` (set to `temporal` for dedicated DB)
3. If postgres not available, gracefully falls back to SQLite

**Manual postgres service control:**
```bash
# Activate with postgres configured
TEMPORAL_STORAGE_TYPE=postgres PGDATABASE=temporal flox activate

# Start postgres service
flox services start postgres

# Start temporal server
flox services start temporal-server
```

## Commands

### Service Management
```bash
flox services status                    # Check all services
flox services logs temporal-server      # View server logs
flox services logs postgres             # View postgres logs (if using)
```

### Temporal CLI
```bash
temporal --version                      # Show Temporal version
temporal operator namespace list        # List namespaces
temporal workflow list                  # List workflows
```

## Services

This environment provides one main service:

- **temporal-server** - Unified server (frontend, history, matching, worker)

When PostgreSQL composition is used, the `postgres` service is also available.

## Files & Directories

```
$TEMPORAL_HOME/
├── config.yaml               # Auto-generated configuration
├── temporal.db               # SQLite database (SQLite mode)
├── temporal_visibility.db    # SQLite visibility DB (SQLite mode)
└── logs/                     # Service logs
```

## Architecture

**SQLite Mode (Default):**
```
temporal-server ──> SQLite DBs
```

**PostgreSQL Mode (Composed):**
```
temporal-server ──> PostgreSQL
        │
        └──> postgres service (from composition)
```

## Troubleshooting

### Services won't start
```bash
# Check service status
flox services status

# View logs
flox services logs temporal-server

# Check port availability
netstat -tuln | grep 7233

# Restart services
flox services restart temporal-server
```

### PostgreSQL connection issues
```bash
# Verify postgres is running
flox services status postgres

# Check connection URL
echo $TEMPORAL_POSTGRES_URL

# Test postgres connectivity
pg_isready -h $PGHOSTADDR -p $PGPORT

# Verify database exists
psql -l
```

### Worker not executing tasks
```bash
# Check temporal server is running
flox services status temporal-server
flox services logs temporal-server

# Check namespace exists
temporal operator namespace describe default

# Check workflow list
temporal workflow list
```

## Composition

This environment can be included in other Flox environments:

```toml
# In your manifest.toml
[include]
environments = [
  { remote = "barstoolbluz/temporal-headless" }
]
```

All temporal commands and services become available in your composed environment.

## Use Cases

- **CI/CD Pipelines** - Automated workflow testing and deployment
- **Docker Containers** - Containerized Temporal deployments
- **Kubernetes** - K8s-native workflow orchestration
- **Production Deployments** - Production-grade orchestration
- **Multi-tenant** - Multiple isolated Temporal instances
- **Development** - Fast local development with SQLite

## Production Considerations

**Security:**
- Use PostgreSQL for production (SQLite not suitable for concurrent access)
- Secure postgres connection strings via secrets management
- Never expose server on 0.0.0.0 without firewall/reverse proxy
- Use TLS for gRPC connections in production

**Performance:**
- Use PostgreSQL with connection pooling for high-throughput workloads
- Monitor server logs for workflow execution delays
- Adjust history shard count based on throughput needs
- Consider dedicated PostgreSQL instance for scale

**High Availability:**
- Run multiple frontend/history/matching service instances behind load balancer
- Use PostgreSQL with replication for storage backend
- Deploy on Kubernetes with appropriate resource limits and probes
- Set up proper health checks and readiness probes

**Monitoring:**
- Health check endpoint: gRPC health check on port 7233
- Monitor server process health
- Track workflow queue depth and execution times via Temporal UI
- Set up alerts for failed workflows

## Links

- [Temporal Documentation](https://docs.temporal.io/)
- [Temporal GitHub](https://github.com/temporalio/temporal)
- [Server Configuration Reference](https://docs.temporal.io/references/configuration)
- [Self-Hosting Guide](https://docs.temporal.io/self-hosted-guide)

---

**Version:** Temporal 1.29.1 with PostgreSQL support
**FloxHub:** `barstoolbluz/temporal-headless`
