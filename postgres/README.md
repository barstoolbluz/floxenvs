# 🐘 Flox Environment for PostgreSQL (Headless)

This `postgres` environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

The [`postgres`](https://github.com/barstoolbluz/floxenvs/tree/main/postgres/) environment is better for local, interactive use—especially when users need help configuring their database step by step with interactive wizards.

## ✨ Features

- **30 configuration variables** for complete control over PostgreSQL
- **Dynamic runtime configuration** - change settings by restarting the service
- **Safety warnings** for dangerous configurations (fsync=off, trust auth, network exposure)
- **Complete performance tuning** - connection limits, memory, WAL, logging
- **Automatic database creation** - specify PGDATABASE and it's created automatically
- **PostGIS extension** preinstalled for spatial data
- **Cross-platform compatibility** (Linux x86_64 and ARM64, macOS x86_64 and ARM64)
- **No interactive wizards or prompts** - perfect for CI/CD pipelines

## 🧰 Included Tools

- `postgresql_16` - PostgreSQL database server
- `postgis` - Spatial extension for geographic data
- All standard PostgreSQL tools (`psql`, `createdb`, `pg_dump`, etc.)

## 🏁 Getting Started

### 📋 Prerequisites

- [Flox](https://flox.dev/get) installed on your system
- That's it.

### 💻 Installation & Activation

```bash
# Pull the environment
flox pull --copy barstoolbluz/postgres

# Activate (without starting services)
cd postgres
flox activate

# Or activate and start PostgreSQL immediately
flox activate -s
```

### 🎮 Basic Usage

```bash
# Start with default configuration
flox activate -s

# Connect to database
psql

# Show configuration
postgres-info

# View logs
flox services logs postgres

# Stop service
flox services stop postgres
```

## ⚙️ Configuration Variables

### Variable Categories

This environment supports **30 configuration variables** organized into two categories:

**Init-Time Variables (7)** - Affect database initialization. To change these, you must delete `$PGDATA` and reinitialize.

**Runtime Variables (20)** - Affect the running PostgreSQL server. Change these anytime by restarting the service.

### Init-Time Variables

These variables affect `initdb` and cannot be changed without reinitializing the database:

| Variable | Default | Description |
|----------|---------|-------------|
| `PGUSER` | `pguser` | Database superuser name |
| `PGPASSWORD` | `pgpass` | Database superuser password |
| `POSTGRES_HOST_AUTH_METHOD` | `md5` | Authentication method (`md5`, `scram-sha-256`, `trust`) |
| `POSTGRES_ENCODING` | `UTF8` | Database encoding |
| `POSTGRES_LOCALE` | `C` | Database locale |
| `POSTGRES_DATA_CHECKSUMS` | *(empty)* | Enable data checksums (set to any non-empty value) |
| `POSTGRES_INITDB_ARGS` | *(empty)* | Additional arguments to pass to `initdb` |

**To change init-time variables:**
```bash
# Stop service, delete data, restart
flox services stop postgres
rm -rf $POSTGRES_DIR/data
PGUSER=newuser PGPASSWORD=newpass flox activate -s
```

### Runtime Variables

These variables can be changed by restarting the PostgreSQL service:

#### Connection (4 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `PGHOSTADDR` | `127.0.0.1` | Server listen address (use `0.0.0.0` for network access) |
| `PGPORT` | `15432` | Server port |
| `PGHOST` | *(empty)* | Client connection host (empty = Unix socket) |
| `PGDATABASE` | `postgres` | Default database (auto-created if not `postgres`) |

#### Performance - Basic (4 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_MAX_CONNECTIONS` | `100` | Maximum concurrent connections |
| `POSTGRES_SHARED_BUFFERS` | `128MB` | Shared memory buffer size |
| `POSTGRES_WORK_MEM` | `4MB` | Memory per sort/hash operation |
| `POSTGRES_EFFECTIVE_CACHE_SIZE` | `4GB` | Planner's assumption of OS cache size |

#### Performance - Durability (3 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_FSYNC` | `on` | Force disk writes (set to `off` for 10x faster CI tests) |
| `POSTGRES_SYNCHRONOUS_COMMIT` | `on` | Wait for disk write confirmation |
| `POSTGRES_FULL_PAGE_WRITES` | `on` | Write full pages after checkpoint |

#### Performance - WAL (3 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_MAX_WAL_SIZE` | `1GB` | Maximum WAL size before checkpoint |
| `POSTGRES_MIN_WAL_SIZE` | `80MB` | Minimum WAL size to keep |
| `POSTGRES_CHECKPOINT_TIMEOUT` | `5min` | Maximum time between checkpoints |

#### Logging (5 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_LOG_STATEMENT` | `none` | Log statements (`none`, `ddl`, `mod`, `all`) |
| `POSTGRES_LOG_DURATION` | `off` | Log statement duration |
| `POSTGRES_LOG_MIN_DURATION` | *(empty)* | Log statements slower than this (e.g., `1000ms`) |
| `POSTGRES_LOG_CONNECTIONS` | `off` | Log connection attempts |
| `POSTGRES_LOG_DISCONNECTIONS` | `off` | Log disconnections |

#### Flexibility (1 variable)

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_EXTRA_OPTS` | *(empty)* | Additional PostgreSQL command-line options |

**To change runtime variables:**
```bash
# Just restart the service with new values
flox services stop postgres
POSTGRES_MAX_CONNECTIONS=200 POSTGRES_FSYNC=off flox services start postgres
```

### Derived Variables

These are automatically set based on other variables:

| Variable | Value | Description |
|----------|-------|-------------|
| `POSTGRES_DIR` | `$FLOX_ENV_CACHE/postgres-data` | PostgreSQL base directory |
| `PGDATA` | `$POSTGRES_DIR/data` | PostgreSQL data directory |
| `PGHOST_SOCKET` | `$POSTGRES_DIR/run` | Unix socket directory |

## 🔒 Security Warnings

The environment displays warnings when dangerous settings are used:

### ⚠️ POSTGRES_FSYNC=off
**Warning:** `fsync disabled - DATA LOSS RISK if crash occurs`

**When to use:** CI/testing only (10x faster but data can be lost on crash)
```bash
POSTGRES_FSYNC=off flox activate -s
```

### ⚠️ POSTGRES_HOST_AUTH_METHOD=trust
**Warning:** `Authentication disabled - NO PASSWORD REQUIRED`

**When to use:** Local development only (anyone can connect without password)
```bash
POSTGRES_HOST_AUTH_METHOD=trust flox activate -s
```

### ⚠️ PGHOSTADDR=0.0.0.0
**Warning:** `Listening on all interfaces - NETWORK EXPOSED`

**When to use:** When you need network access from other machines (ensure firewall is configured)
```bash
PGHOSTADDR=0.0.0.0 PGHOST=0.0.0.0 flox activate -s
```

## 📋 Usage Examples

### Basic Usage (Defaults)

```bash
flox activate -s
# PostgreSQL on 127.0.0.1:15432, Unix socket, 100 connections, fsync=on
```

### CI/Testing Optimizations

```bash
POSTGRES_FSYNC=off \
POSTGRES_SYNCHRONOUS_COMMIT=off \
POSTGRES_MAX_CONNECTIONS=20 \
POSTGRES_LOG_STATEMENT=all \
flox activate -s
# 10x faster, good for tests, logs all queries
```

### Network Access

```bash
PGHOSTADDR=0.0.0.0 \
PGHOST=0.0.0.0 \
PGPORT=5432 \
flox activate -s
# Listen on all interfaces, clients connect via TCP
```

### Custom Performance Tuning

```bash
POSTGRES_MAX_CONNECTIONS=500 \
POSTGRES_SHARED_BUFFERS=2GB \
POSTGRES_WORK_MEM=16MB \
POSTGRES_EFFECTIVE_CACHE_SIZE=8GB \
flox activate -s
# Tuned for high-traffic server
```

### Debug Mode

```bash
POSTGRES_LOG_STATEMENT=all \
POSTGRES_LOG_DURATION=on \
POSTGRES_LOG_CONNECTIONS=on \
POSTGRES_LOG_DISCONNECTIONS=on \
POSTGRES_LOG_MIN_DURATION=0 \
flox activate -s
# Full query logging for debugging
```

### Custom Database Creation

```bash
PGDATABASE=myapp \
PGUSER=appuser \
PGPASSWORD=secure123 \
flox activate -s
# Creates 'myapp' database automatically
```

### Advanced: Custom PostgreSQL Options

```bash
POSTGRES_EXTRA_OPTS="-c max_wal_size=2GB -c checkpoint_timeout=30min" \
flox activate -s
# Escape hatch for any PostgreSQL setting
```

## 🔧 Advanced Usage

### Change Settings Without Reinitializing

```bash
# First run
flox activate -s

# Later, change settings (just restart service)
flox services stop postgres

POSTGRES_MAX_CONNECTIONS=200 \
POSTGRES_FSYNC=off \
flox services start postgres
# Works! No reinitialization needed
```

### Authentication Modes

```bash
# Trust (no password) - local dev only
POSTGRES_HOST_AUTH_METHOD=trust flox activate -s

# MD5 (default) - basic security
POSTGRES_HOST_AUTH_METHOD=md5 flox activate -s

# SCRAM (most secure) - production
POSTGRES_HOST_AUTH_METHOD=scram-sha-256 flox activate -s
```

### Unix Socket vs TCP Connection

```bash
# Unix socket (default, fastest)
flox activate -s
psql  # Connects via Unix socket

# TCP connection
PGHOST=localhost flox activate -s
psql  # Connects via TCP to localhost
```

### Multiple PostgreSQL Instances

```bash
# Terminal 1: Development database
PGPORT=15432 PGDATABASE=dev POSTGRES_DIR=/tmp/pg-dev flox activate -s

# Terminal 2: Test database
PGPORT=15433 PGDATABASE=test POSTGRES_DIR=/tmp/pg-test flox activate -s
```

### PostGIS Extension

```bash
psql -c "CREATE EXTENSION postgis;"
psql -c "SELECT PostGIS_Version();"
```

### Using in CI/CD

#### GitHub Actions

```yaml
- name: Setup PostgreSQL
  run: |
    flox pull --copy barstoolbluz/postgres
    cd postgres
    POSTGRES_FSYNC=off PGDATABASE=testdb flox activate -s -- sleep 2

- name: Run tests
  run: |
    cd postgres
    flox activate -- psql -c "SELECT version();"
    flox activate -- pytest tests/
```

#### GitLab CI

```yaml
test:
  before_script:
    - flox pull --copy barstoolbluz/postgres
    - cd postgres
    - POSTGRES_FSYNC=off flox activate -s -- sleep 2
  script:
    - flox activate -- psql -c "CREATE TABLE test (id SERIAL);"
    - flox activate -- pytest
```

## 📝 Common Commands

Inside the activated environment:

```bash
# Show full configuration
postgres-info

# Connect to database
psql

# Create a database
createdb mynewdb

# Dump database
pg_dump $PGDATABASE > backup.sql

# Restore database
psql $PGDATABASE < backup.sql

# Service management
flox services start postgres
flox services stop postgres
flox services restart postgres
flox services logs postgres
flox services status
```

## 🐛 Troubleshooting

### PostgreSQL Won't Start

**Check if port is already in use:**
```bash
lsof -i :$PGPORT
# Or use a different port
PGPORT=5433 flox activate -s
```

**View service logs:**
```bash
flox services logs postgres
```

**Check initialization:**
```bash
# If initialization failed, delete and retry
rm -rf $POSTGRES_DIR/data
flox activate -s
```

### Connection Issues

**Verify connection details:**
```bash
postgres-info
```

**Test connection with explicit parameters:**
```bash
psql -h $PGHOSTADDR -p $PGPORT -U $PGUSER $PGDATABASE
```

**Check if service is running:**
```bash
flox services status
```

### Permission Errors

**Ensure data directory is accessible:**
```bash
ls -ld $POSTGRES_DIR/data
# Should show drwx------ (700 permissions)
```

**Reset permissions:**
```bash
chmod 700 $POSTGRES_DIR/data
```

### Service Won't Start

**Check for conflicting postgres processes:**
```bash
ps aux | grep postgres
# Kill any conflicting processes
```

**Check initialization logs:**
```bash
cat $POSTGRES_DIR/data/log/postgresql-*.log
```

### Reinitialize Database

**To completely reset:**
```bash
flox services stop postgres
rm -rf $POSTGRES_DIR
flox activate -s
```

### Performance Issues

**Check current settings:**
```bash
postgres-info
```

**Increase memory for better performance:**
```bash
POSTGRES_SHARED_BUFFERS=2GB \
POSTGRES_WORK_MEM=16MB \
POSTGRES_EFFECTIVE_CACHE_SIZE=8GB \
flox services restart postgres
```

**Enable logging to diagnose slow queries:**
```bash
POSTGRES_LOG_MIN_DURATION=1000 \
POSTGRES_LOG_STATEMENT=all \
flox services restart postgres
```

## 📚 Variable Reference Quick Guide

### Must Reinitialize to Change (Init-Time)
- `PGUSER`, `PGPASSWORD`, `POSTGRES_HOST_AUTH_METHOD`
- `POSTGRES_ENCODING`, `POSTGRES_LOCALE`
- `POSTGRES_DATA_CHECKSUMS`, `POSTGRES_INITDB_ARGS`

**How to change:** `rm -rf $POSTGRES_DIR/data && flox activate -s`

### Can Change Anytime (Runtime)
- Connection: `PGHOSTADDR`, `PGPORT`, `PGHOST`, `PGDATABASE`
- Performance: `POSTGRES_MAX_CONNECTIONS`, `POSTGRES_SHARED_BUFFERS`, `POSTGRES_WORK_MEM`, `POSTGRES_EFFECTIVE_CACHE_SIZE`, `POSTGRES_FSYNC`, `POSTGRES_SYNCHRONOUS_COMMIT`, `POSTGRES_FULL_PAGE_WRITES`
- WAL: `POSTGRES_MAX_WAL_SIZE`, `POSTGRES_MIN_WAL_SIZE`, `POSTGRES_CHECKPOINT_TIMEOUT`
- Logging: `POSTGRES_LOG_STATEMENT`, `POSTGRES_LOG_DURATION`, `POSTGRES_LOG_MIN_DURATION`, `POSTGRES_LOG_CONNECTIONS`, `POSTGRES_LOG_DISCONNECTIONS`
- Flexibility: `POSTGRES_EXTRA_OPTS`

**How to change:** `flox services restart postgres` (or `stop` then `start` with new variables)

## 🔗 Related Environments

- **[postgres](https://github.com/barstoolbluz/floxenvs/tree/main/postgres/)** - Interactive version with wizards and helpers
- **[postgres-metabase](https://github.com/barstoolbluz/floxenvs/)** - PostgreSQL with Metabase analytics

## 📚 Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Configuration Reference](https://www.postgresql.org/docs/current/runtime-config.html)
- [PostGIS Documentation](https://postgis.net/documentation/)
- [Flox Documentation](https://flox.dev/docs)

## 🤝 Contributing

Found a bug or want to improve this environment? Contributions welcome!

## 📄 License

This environment configuration is provided as-is for use with Flox.
