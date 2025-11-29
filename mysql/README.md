# 🐬 Flox Environment for MySQL 8.0 (Headless)

This `mysql` environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

The [`mysql`](https://github.com/barstoolbluz/floxenvs/tree/main/mysql/) environment is better for local, interactive use—especially when users need help configuring things step by step.

## ✨ Features

- **29 configuration variables** for complete control
- **Dynamic runtime configuration** - change settings by restarting service
- **Safety warnings** for dangerous configurations
- **Automatic database creation** - specify MYSQL_DATABASE and it's created
- MySQL 8.0 with mysql_native_password for compatibility
- X Protocol disabled (--mysqlx=0) for dev use
- No interactive prompts - pure environment variables

## 🚀 Getting Started

### Basic Usage (Defaults)

```bash
cd mysql
flox activate -s
# MySQL on 127.0.0.1:13306, root password: mysqlpass
```

### Custom Configuration

```bash
MYSQL_PORT=3306 \
MYSQL_ROOT_PASSWORD=secret123 \
MYSQL_DATABASE=myapp \
flox activate -s
```

## ⚙️ Configuration Variables

### Init-Time Variables (7)
Cannot change without deleting `$MYSQL_DATADIR`:

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_ROOT_PASSWORD` | `mysqlpass` | Root password |
| `MYSQL_USER` | *(empty)* | Additional user to create |
| `MYSQL_PASSWORD` | *(empty)* | Password for additional user |
| `MYSQL_CHARSET` | `utf8mb4` | Character set |
| `MYSQL_COLLATION` | `utf8mb4_unicode_ci` | Collation |
| `MYSQL_AUTH_PLUGIN` | `mysql_native_password` | Auth plugin |
| `MYSQL_INIT_ARGS` | *(empty)* | Extra initialization args |

### Runtime Variables (22)
Can change by restarting service:

**Connection (3):**
- `MYSQL_BIND_ADDRESS` (default: `127.0.0.1`)
- `MYSQL_PORT` (default: `13306`)
- `MYSQL_DATABASE` (default: `mysql`)

**Performance - Basic (5):**
- `MYSQL_MAX_CONNECTIONS` (default: `151`)
- `MYSQL_INNODB_BUFFER_POOL_SIZE` (default: `128M`)
- `MYSQL_TMP_TABLE_SIZE` (default: `16M`)
- `MYSQL_MAX_HEAP_TABLE_SIZE` (default: `16M`)
- `MYSQL_THREAD_CACHE_SIZE` (default: `9`)

**Performance - Query Memory (2):**
- `MYSQL_SORT_BUFFER_SIZE` (default: `256K`)
- `MYSQL_JOIN_BUFFER_SIZE` (default: `256K`)

**Performance - InnoDB (4):**
- `MYSQL_INNODB_LOG_FILE_SIZE` (default: `48M`)
- `MYSQL_INNODB_FLUSH_LOG_AT_TRX_COMMIT` (default: `1`)
- `MYSQL_INNODB_FLUSH_METHOD` (default: *(auto)*)
- `MYSQL_INNODB_FILE_PER_TABLE` (default: `ON`)

**Logging (3):**
- `MYSQL_SLOW_QUERY_LOG` (default: `OFF`)
- `MYSQL_LONG_QUERY_TIME` (default: `10`)
- `MYSQL_LOG_BIN` (default: *(empty, disabled)*)

**Binary Log Management (4):**
- `MYSQL_BINLOG_FORMAT` (default: `MIXED`)
- `MYSQL_MAX_BINLOG_SIZE` (default: `1G`)
- `MYSQL_BINLOG_EXPIRE_LOGS_SECONDS` (default: `2592000` = 30 days)
- `MYSQL_SYNC_BINLOG` (default: `1`)

**Flexibility (1):**
- `MYSQL_EXTRA_OPTS` - Additional mysqld options

## 📋 Usage Examples

### CI/Testing Optimizations

```bash
MYSQL_INNODB_FLUSH_LOG_AT_TRX_COMMIT=2 \
MYSQL_MAX_CONNECTIONS=50 \
MYSQL_SLOW_QUERY_LOG=ON \
MYSQL_LONG_QUERY_TIME=1 \
flox activate -s
# Faster for tests, logs slow queries
```

### Network Access

```bash
MYSQL_BIND_ADDRESS=0.0.0.0 \
MYSQL_PORT=3306 \
flox activate -s
# ⚠️  WARNING: Network exposed!
```

### Custom Performance Tuning

```bash
MYSQL_MAX_CONNECTIONS=500 \
MYSQL_INNODB_BUFFER_POOL_SIZE=2G \
MYSQL_TMP_TABLE_SIZE=64M \
MYSQL_MAX_HEAP_TABLE_SIZE=64M \
flox activate -s
```

### Create Database and User

```bash
MYSQL_DATABASE=myapp \
MYSQL_USER=appuser \
MYSQL_PASSWORD=apppass \
MYSQL_ROOT_PASSWORD=rootpass \
flox activate -s
```

### Change Settings Without Reinitializing

```bash
# First run
flox activate -s

# Later, change settings
flox services stop mysql
MYSQL_MAX_CONNECTIONS=200 flox services start mysql
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
mysql-info

# Connect
mysql -u root -p
# Password: value of MYSQL_ROOT_PASSWORD

# Service management
flox services status
flox services logs mysql
flox services restart mysql
```

## 🐛 Troubleshooting

### Reinitialize Database

```bash
flox services stop mysql
rm -rf $MYSQL_DIR
flox activate -s
```

### Check Configuration

```bash
mysql-info
```

### Connection Issues

```bash
# Check socket
ls -la $MYSQL_SOCKET

# Check logs
tail -f $MYSQL_LOG_ERROR
```

## 🔗 Related Environments

- **[mysql-local](../mysql-local/)** - Interactive version with wizard
- **[mariadb](../mariadb/)** - MariaDB headless variant
- **[postgres](../postgres/)** - PostgreSQL headless variant

## 📚 Resources

- [MySQL 8.0 Documentation](https://dev.mysql.com/doc/refman/8.0/en/)
- [MySQL Configuration Variables](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html)
