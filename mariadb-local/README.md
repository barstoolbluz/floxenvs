# 🦭 Flox Environment for MariaDB

This `mariadb` environment is designed for local, interactive use—especially when users need help configuring things step by step with interactive wizards.

The [`mariadb-headless`](https://github.com/barstoolbluz/floxenvs/tree/main/mariadb-headless/) environment is better for CI, headless setups, or scripted workflows.

## ✨ Features

- Interactive configuration wizard using `gum`
- MariaDB with unix_socket and password authentication
- Automatic database initialization
- Service management wrappers
- Default port 13307 (avoids conflicts with MySQL)
- Cross-platform compatibility (Linux x86_64/ARM64, macOS x86_64/ARM64)
- MariaDB-specific features (thread pool, Galera, etc.)

## 🚀 Getting Started

### Activate and Configure

```bash
cd mariadb
flox activate
# Follow the interactive wizard
```

The wizard will ask:
- Bind address (default: 127.0.0.1)
- Port (default: 13307)
- Root password (default: mariadbpass)
- Database name (default: mysql)
- Data directory location

### Start MariaDB

```bash
flox activate -s
# Or after activation:
mariadbstart
```

### Connect

```bash
mysql -u root -p
# Enter the root password you configured
```

## ⚙️ Configuration

Configuration is saved to `$FLOX_ENV_CACHE/mariadb.config` after first run.

### Reconfigure

```bash
# Inside activated environment:
mariadbconfigure
```

This will:
1. Stop MariaDB
2. Re-run the configuration wizard
3. Reinitialize the database
4. Restart MariaDB

## 📝 Common Commands

Inside the activated environment:

```bash
# Service management
mariadbstart          # Start MariaDB
mariadbstop           # Stop MariaDB
mariadbrestart        # Restart MariaDB
mariadbconfigure      # Reconfigure MariaDB

# Database operations
mysql -u root -p                        # Connect
mysqldump mydb > backup.sql             # Backup (or mariadb-dump)
mysql -u root -p mydb < backup.sql      # Restore
mysql -u root -p -e "SHOW DATABASES;"   # List databases
```

## 🔧 Advanced Usage

### Network Access

To allow network connections, configure with bind address `0.0.0.0` during the wizard.

### Custom Data Directory

The wizard allows specifying a custom data directory. Useful for:
- Persistent storage locations
- Shared storage
- Performance optimization (SSD vs HDD)

### Debug Mode

Set `MARIADB_DEBUG=true` before activation to see detailed output.

### MariaDB-Specific Features

MariaDB includes features not in MySQL:
- **Galera Cluster** (built-in clustering)
- **Thread Pool** (better connection handling)
- **Multiple Storage Engines** (Aria, ColumnStore, Spider)
- **Temporal Tables** (system-versioned tables)
- **Oracle Compatibility** (PL/SQL-like syntax)

## 🐛 Troubleshooting

### Port Already in Use

```bash
lsof -i :13307
# Use a different port during configuration
```

### Connection Refused

```bash
# Check if MariaDB is running
flox services status

# Check logs
flox services logs mariadb
```

### Reset Everything

```bash
rm -rf $FLOX_ENV_CACHE/mariadb*
flox activate
# Re-run wizard
```

## 🔗 Related Environments

- **[mariadb-headless](../mariadb-headless/)** - Headless variant for CI/CD
- **[mysql](../mysql/)** - MySQL 8.0 with interactive setup
- **[postgres](../postgres/)** - PostgreSQL with interactive setup

## 📚 Resources

- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [MariaDB vs MySQL](https://mariadb.com/kb/en/mariadb-vs-mysql-features/)
- [Flox Documentation](https://flox.dev/docs)
