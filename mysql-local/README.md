# 🐬 Flox Environment for MySQL 8.0

This `mysql` environment is designed for local, interactive use—especially when users need help configuring things step by step with interactive wizards.

The [`mysql-headless`](https://github.com/barstoolbluz/floxenvs/tree/main/mysql-headless/) environment is better for CI, headless setups, or scripted workflows.

## ✨ Features

- Interactive configuration wizard using `gum`
- MySQL 8.0 with mysql_native_password authentication
- Automatic database initialization
- Service management wrappers
- Default port 13306 (avoids conflicts)
- Cross-platform compatibility (Linux x86_64/ARM64, macOS x86_64/ARM64)

## 🚀 Getting Started

### Activate and Configure

```bash
cd mysql
flox activate
# Follow the interactive wizard
```

The wizard will ask:
- Bind address (default: 127.0.0.1)
- Port (default: 13306)
- Root password (default: mysqlpass)
- Database name (default: mysql)
- Data directory location

### Start MySQL

```bash
flox activate -s
# Or after activation:
mysqlstart
```

### Connect

```bash
mysql -u root -p
# Enter the root password you configured
```

## ⚙️ Configuration

Configuration is saved to `$FLOX_ENV_CACHE/mysql.config` after first run.

### Reconfigure

```bash
# Inside activated environment:
mysqlconfigure
```

This will:
1. Stop MySQL
2. Re-run the configuration wizard
3. Reinitialize the database
4. Restart MySQL

## 📝 Common Commands

Inside the activated environment:

```bash
# Service management
mysqlstart          # Start MySQL
mysqlstop           # Stop MySQL
mysqlrestart        # Restart MySQL
mysqlconfigure      # Reconfigure MySQL

# Database operations
mysql -u root -p                        # Connect
mysqldump mydb > backup.sql             # Backup
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

Set `MYSQL_DEBUG=true` before activation to see detailed output.

## 🐛 Troubleshooting

### Port Already in Use

```bash
lsof -i :13306
# Use a different port during configuration
```

### Connection Refused

```bash
# Check if MySQL is running
flox services status

# Check logs
flox services logs mysql
```

### Reset Everything

```bash
rm -rf $FLOX_ENV_CACHE/mysql*
flox activate
# Re-run wizard
```

## 🔗 Related Environments

- **[mysql-headless](../mysql-headless/)** - Headless variant for CI/CD
- **[mariadb](../mariadb/)** - MariaDB with interactive setup
- **[postgres](../postgres/)** - PostgreSQL with interactive setup

## 📚 Resources

- [MySQL 8.0 Documentation](https://dev.mysql.com/doc/refman/8.0/en/)
- [Flox Documentation](https://flox.dev/docs)
