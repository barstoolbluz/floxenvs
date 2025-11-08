# Dagster (Headless Mode)

Dagster orchestration platform with optional PostgreSQL support via composition. Headless mode for automation, CI/CD, and production deployments.

## Features

- ✅ **Dagster 1.12.0** complete platform (webserver, daemon, GraphQL API)
- ✅ **SQLite storage** (default) - fast local development
- ✅ **PostgreSQL support** (optional) - production-ready via composition
- ✅ **Auto-configuration** - smart detection and connection URL generation
- ✅ **Zero interaction** - all configuration via environment variables
- ✅ **Container-friendly** - no TTY required, perfect for Docker/K8s

## Quick Start

### Default (SQLite)
```bash
flox activate -s
# Dagster running with SQLite at http://127.0.0.1:3000
```

### With PostgreSQL
```bash
DAGSTER_STORAGE_TYPE=postgres PGDATABASE=dagster flox activate -s
# Dagster running with PostgreSQL at http://127.0.0.1:3000
```

## Configuration

### Core Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `DAGSTER_HOME` | `$FLOX_ENV_CACHE/dagster-data` | Instance metadata directory |
| `DAGSTER_HOST` | `127.0.0.1` | Webserver bind address |
| `DAGSTER_PORT` | `3000` | Webserver port |

### Storage Backend

| Variable | Default | Description |
|----------|---------|-------------|
| `DAGSTER_STORAGE_TYPE` | `sqlite` | Storage type (`sqlite` or `postgres`) |
| `DAGSTER_POSTGRES_URL` | (auto) | PostgreSQL connection URL (auto-generated if not provided) |

### Compute

| Variable | Default | Description |
|----------|---------|-------------|
| `DAGSTER_RUN_LAUNCHER` | (default) | Run launcher class |
| `DAGSTER_MAX_CONCURRENT_RUNS` | `10` | Max concurrent pipeline runs |

### Code Location

| Variable | Default | Description |
|----------|---------|-------------|
| `DAGSTER_CODE_LOCATION_NAME` | - | Name for code location |
| `DAGSTER_MODULE_NAME` | - | Python module containing definitions |
| `DAGSTER_WORKING_DIRECTORY` | - | Working directory for code |

### Control Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `DAGSTER_SKIP_INIT` | - | Set to `1` to skip config generation |
| `DAGSTER_QUIET` | - | Set to `1` to suppress welcome message |

## Usage Examples

### Local Development (SQLite)
```bash
flox activate -s
```

### Production (PostgreSQL - Auto-configured)
```bash
# PostgreSQL variables from composed postgres-headless environment
DAGSTER_STORAGE_TYPE=postgres \
PGDATABASE=dagster \
flox activate -s
```

### Production (PostgreSQL - Custom Server)
```bash
DAGSTER_STORAGE_TYPE=postgres \
DAGSTER_POSTGRES_URL="postgresql://user:pass@prod-db:5432/dagster" \
flox activate -s
```

### CI/CD Pipeline
```bash
# Dockerfile example
FROM ubuntu:22.04
RUN curl -fsSL https://get.flox.dev | bash
COPY . /app
WORKDIR /app
ENV DAGSTER_STORAGE_TYPE=postgres
ENV DAGSTER_POSTGRES_URL="postgresql://user:pass@postgres:5432/dagster"
CMD ["flox", "activate", "-s"]
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dagster
spec:
  template:
    spec:
      containers:
      - name: dagster-webserver
        image: your-flox-image
        env:
        - name: DAGSTER_STORAGE_TYPE
          value: "postgres"
        - name: DAGSTER_POSTGRES_URL
          valueFrom:
            secretKeyRef:
              name: dagster-db
              key: connection-url
        - name: DAGSTER_HOST
          value: "0.0.0.0"
        command: ["flox", "activate", "--", "dagster-webserver"]
```

## PostgreSQL Composition

This environment includes `barstoolbluz/postgres-headless` for optional PostgreSQL support.

**How it works:**
1. When `DAGSTER_STORAGE_TYPE=postgres`, Dagster auto-detects the composed PostgreSQL environment
2. Connection URL is auto-generated from postgres environment variables:
   - `PGUSER` (default: `pguser`)
   - `PGPASSWORD` (default: `pgpass`)
   - `PGHOSTADDR` (default: `127.0.0.1`)
   - `PGPORT` (default: `15432`)
   - `PGDATABASE` (set to `dagster` for dedicated DB)
3. If postgres not available, gracefully falls back to SQLite

**Manual postgres service control:**
```bash
# Activate with postgres configured
DAGSTER_STORAGE_TYPE=postgres PGDATABASE=dagster flox activate

# Start postgres service
flox services start postgres

# Start dagster services
flox services start dagster-webserver
flox services start dagster-daemon
```

## Commands

### Service Management
```bash
flox services status                    # Check all services
flox services logs dagster-webserver    # View webserver logs
flox services logs dagster-daemon       # View daemon logs
flox services logs postgres             # View postgres logs (if using)
```

### Dagster CLI
```bash
dagster --version                       # Show Dagster version
dagster instance info                   # Show instance details
dagster-info                            # Show configuration
```

## Services

This environment provides two services:

- **dagster-webserver** - Web UI and GraphQL API (port 3000)
- **dagster-daemon** - Background daemon for schedules and sensors

When PostgreSQL composition is used, the `postgres` service is also available.

## Files & Directories

```
$DAGSTER_HOME/
├── dagster.yaml              # Generated instance configuration
├── history/                  # Run history (SQLite mode)
├── schedules/                # Schedule storage (SQLite mode)
└── storage/                  # Compute logs

$DAGSTER_STORAGE_DIR/         # Artifact storage
```

## Architecture

**SQLite Mode (Default):**
```
dagster-webserver ─┐
                   ├─> SQLite DBs
dagster-daemon ────┘
```

**PostgreSQL Mode (Composed):**
```
dagster-webserver ─┐
                   ├─> PostgreSQL
dagster-daemon ────┘
        │
        └─> postgres service (from composition)
```

## Troubleshooting

### Services won't start
```bash
# Check service status
flox services status

# View logs
flox services logs dagster-webserver
flox services logs dagster-daemon

# Restart services
flox services restart dagster-webserver
```

### PostgreSQL connection issues
```bash
# Verify postgres is running
flox services status postgres

# Check connection URL
echo $DAGSTER_POSTGRES_URL

# Test postgres connectivity
pg_isready -h $PGHOSTADDR -p $PGPORT
```

### Configuration not applied
```bash
# Check generated config
cat $DAGSTER_HOME/dagster.yaml

# Regenerate config (delete and reactivate)
rm $DAGSTER_HOME/dagster.yaml
DAGSTER_STORAGE_TYPE=postgres flox activate
```

## Composition

This environment can be included in other Flox environments:

```toml
# In your manifest.toml
[include]
environments = [
  { remote = "barstoolbluz/dagster-headless" }
]
```

All dagster commands and services become available in your composed environment.

## Use Cases

- **CI/CD Pipelines** - Automated data pipeline testing and deployment
- **Docker Containers** - Containerized Dagster deployments
- **Kubernetes** - K8s-native Dagster orchestration
- **Production Deployments** - Production-grade data orchestration
- **Multi-tenant** - Multiple isolated Dagster instances
- **Development** - Fast local development with SQLite

## Production Considerations

**Security:**
- Set `DAGSTER_HOST=0.0.0.0` only when behind a reverse proxy
- Use PostgreSQL for production (SQLite not suitable for concurrent access)
- Secure postgres connection strings via secrets management

**Performance:**
- Adjust `DAGSTER_MAX_CONCURRENT_RUNS` based on available resources
- Use PostgreSQL with connection pooling for high-throughput workloads
- Monitor `dagster-daemon` logs for schedule/sensor execution

**High Availability:**
- Run multiple `dagster-webserver` instances behind a load balancer
- Use PostgreSQL with replication for storage backend
- Deploy on Kubernetes with pod anti-affinity

## Links

- [Dagster Documentation](https://docs.dagster.io/)
- [Dagster GitHub](https://github.com/dagster-io/dagster)
- [PostgreSQL Deployment](https://docs.dagster.io/deployment/guides/postgres)
- [Kubernetes Deployment](https://docs.dagster.io/deployment/guides/kubernetes)

---

**Version:** Dagster 1.12.0 with PostgreSQL support
**FloxHub:** `barstoolbluz/dagster-headless`
