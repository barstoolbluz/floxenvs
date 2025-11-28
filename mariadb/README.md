# 🦭 Flox Environment for MariaDB (Headless)

This `mariadb-headless` environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

The [`mariadb`](https://github.com/barstoolbluz/floxenvs/tree/main/mariadb/) environment is better for local, interactive use—especially when users need help configuring things step by step.

## ✨ Features

- **29 configuration variables** for complete control
- **Dynamic runtime configuration** - change settings by restarting service
- **Safety warnings** for dangerous configurations
- **Automatic database creation** - specify MARIADB_DATABASE and it's created
- MariaDB with thread pool and advanced features
- No interactive prompts - pure environment variables
- Default port 13307 (avoids MySQL conflicts)

## 🚀 Getting Started

### Basic Usage (Defaults)

```bash
cd mariadb-headless
flox activate -s
# MariaDB on 127.0.0.1:13307, root password: mariadbpass
```

### Custom Configuration

```bash
MARIADB_PORT=3306 \
MARIADB_ROOT_PASSWORD=secret123 \
MARIADB_DATABASE=myapp \
flox activate -s
```

## ⚙️ Configuration Variables

### Init-Time Variables (6)
Cannot change without deleting `$MARIADB_DATADIR`:

| Variable | Default | Description |
|----------|---------|-------------|
| `MARIADB_ROOT_PASSWORD` | `mariadbpass` | Root password |
| `MARIADB_USER` | *(empty)* | Additional user to create |
| `MARIADB_PASSWORD` | *(empty)* | Password for additional user |
| `MARIADB_CHARSET` | `utf8mb4` | Character set |
| `MARIADB_COLLATION` | `utf8mb4_unicode_ci` | Collation |
| `MARIADB_INIT_ARGS` | *(empty)* | Extra initialization args |

### Runtime Variables (23)
Can change by restarting service:

**Connection (3):**
- `MARIADB_BIND_ADDRESS` (default: `127.0.0.1`)
- `MARIADB_PORT` (default: `13307`)
- `MARIADB_DATABASE` (default: `mysql`)

**Performance - Basic (5):**
- `MARIADB_MAX_CONNECTIONS` (default: `151`)
- `MARIADB_INNODB_BUFFER_POOL_SIZE` (default: `128M`)
- `MARIADB_TMP_TABLE_SIZE` (default: `16M`)
- `MARIADB_MAX_HEAP_TABLE_SIZE` (default: `16M`)
- `MARIADB_THREAD_CACHE_SIZE` (default: `9`)

**Performance - Query Memory (2):**
- `MARIADB_SORT_BUFFER_SIZE` (default: `256K`)
- `MARIADB_JOIN_BUFFER_SIZE` (default: `256K`)

**Performance - InnoDB (4):**
- `MARIADB_INNODB_LOG_FILE_SIZE` (default: `96M` - larger than MySQL)
- `MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT` (default: `1`)
- `MARIADB_INNODB_FLUSH_METHOD` (default: *(auto)*)
- `MARIADB_INNODB_FILE_PER_TABLE` (default: `ON`)

**Performance - MariaDB Specific (1):**
- `MARIADB_THREAD_POOL_SIZE` (default: `auto`)

**Logging (3):**
- `MARIADB_SLOW_QUERY_LOG` (default: `OFF`)
- `MARIADB_LONG_QUERY_TIME` (default: `10`)
- `MARIADB_LOG_BIN` (default: *(empty, disabled)*)

**Binary Log Management (4):**
- `MARIADB_BINLOG_FORMAT` (default: `MIXED`)
- `MARIADB_MAX_BINLOG_SIZE` (default: `1G`)
- `MARIADB_BINLOG_EXPIRE_LOGS_SECONDS` (default: `2592000` = 30 days)
- `MARIADB_SYNC_BINLOG` (default: `1`)

**Flexibility (1):**
- `MARIADB_EXTRA_OPTS` - Additional mysqld options

## 📋 Usage Examples

### CI/Testing Optimizations

```bash
MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT=2 \
MARIADB_MAX_CONNECTIONS=50 \
MARIADB_THREAD_POOL_SIZE=4 \
MARIADB_SLOW_QUERY_LOG=ON \
MARIADB_LONG_QUERY_TIME=1 \
flox activate -s
# Faster for tests, uses thread pool, logs slow queries
```

### Network Access

```bash
MARIADB_BIND_ADDRESS=0.0.0.0 \
MARIADB_PORT=3306 \
flox activate -s
# ⚠️  WARNING: Network exposed!
```

### Custom Performance Tuning

```bash
MARIADB_MAX_CONNECTIONS=500 \
MARIADB_INNODB_BUFFER_POOL_SIZE=2G \
MARIADB_THREAD_POOL_SIZE=8 \
MARIADB_TMP_TABLE_SIZE=64M \
MARIADB_MAX_HEAP_TABLE_SIZE=64M \
flox activate -s
```

### Create Database and User

```bash
MARIADB_DATABASE=myapp \
MARIADB_USER=appuser \
MARIADB_PASSWORD=apppass \
MARIADB_ROOT_PASSWORD=rootpass \
flox activate -s
```

### Change Settings Without Reinitializing

```bash
# First run
flox activate -s

# Later, change settings
flox services stop mariadb
MARIADB_MAX_CONNECTIONS=200 MARIADB_THREAD_POOL_SIZE=16 flox services start mariadb
```

## 🔒 Security Warnings

### ⚠️ bind-address=0.0.0.0
**Warning:** `Listening on all interfaces - NETWORK EXPOSED`

**When to use:** Trusted networks only

### ⚠️ innodb_flush_log_at_trx_commit=0 or 2
**Warning:** `DATA LOSS RISK`

**When to use:** CI/testing only (much faster but can lose data on crash)

## 📝 Commands

```bash
# Show configuration
mariadb-info

# Connect
mysql -u root -p
# Password: value of MARIADB_ROOT_PASSWORD

# Service management
flox services status
flox services logs mariadb
flox services restart mariadb
```

## 🔧 MariaDB-Specific Features

MariaDB includes features not in MySQL:

**Thread Pool** - Better connection handling:
```bash
MARIADB_THREAD_POOL_SIZE=auto  # Or set to number of CPUs
```

**Binary Logging** - Disabled by default for dev:
```bash
MARIADB_LOG_BIN=/path/to/binlog  # Enable for replication/PITR
```

**Storage Engines:**
- Aria (enhanced MyISAM)
- ColumnStore (columnar storage)
- Spider (sharding)

## 🐛 Troubleshooting

### Reinitialize Database

```bash
flox services stop mariadb
rm -rf $MARIADB_DIR
flox activate -s
```

### Check Configuration

```bash
mariadb-info
```

### Connection Issues

```bash
# Check socket
ls -la $MARIADB_SOCKET

# Check logs
tail -f $MARIADB_LOG_ERROR
```

## 🔗 Related Environments

- **[mariadb](../mariadb/)** - Interactive version with wizard
- **[mysql-headless](../mysql-headless/)** - MySQL 8.0 headless variant
- **[postgres-headless](../postgres-headless/)** - PostgreSQL headless variant

## 📚 Resources

- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [MariaDB Server Variables](https://mariadb.com/kb/en/server-system-variables/)
- [MariaDB vs MySQL Features](https://mariadb.com/kb/en/mariadb-vs-mysql-features/)
