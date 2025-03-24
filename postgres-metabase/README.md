# 📊 A Flox Environment for PostgreSQL + Metabase

A Flox analytics stack with PostgreSQL and Metabase. Runs locally, no containers or VMs.

## ✨ What's Inside

- PostgreSQL 16 with PostGIS for spatial data
- Metabase for dashboards and visualizations
- Isolated environments that won't break your system
- Custom port configuration to avoid conflicts
- Zero-config service management

## 🧰 Tools at Your Disposal

- `postgresql_16` - Latest PostgreSQL; change to `postgresql_15`, `postgresql_14`, etc. if needed.
- `postgis` - Spatial data extension for GIS work
- `metabase` - BI and analytics platform
- `gum` - TUI for clean setup and management
- `bat` - Powers built-in `readme` function.

## 🚀 Getting Started

### Prerequisites

- [Flox](https://flox.dev/get) installed
- That's all

### One-Step Setup

```sh
flox activate -s
```
### First-Run Setup

The wizard walks you through:

1. Configuring database host, port, username, and password
2. Data directory location
3. Initial database creation

## 📝 Built-in Commands

```bash
# PostgreSQL Control
pgstart    # Start PostgreSQL 
pgstop     # Stop PostgreSQL
pgrestart  # Restart PostgreSQL

# Metabase Control
mbrestart  # Restart Metabase

# Configuration
pgconfigure  # Reconfigure PostgreSQL
```

## 🔧 How It Works

### Database Setup

This Flox environment:
1. Creates an isolated data directory at `$FLOX_ENV_CACHE/postgres`
2. Sets up PostgreSQL with UTF-8 encoding and proper permissions
3. Runs on port 15432 to avoid collisions with existing installations
4. Configures Unix sockets for local connections

### Metabase Configuration

Metabase is preconfigured to:
1. Run on port 3000
2. Listen on all interfaces (0.0.0.0)
3. Store its data in H2 database by default

## 🔌 Connecting

### PostgreSQL

```bash
# Connect directly from shell
psql

# Connect from other tools
Host: 127.0.0.1
Port: 15432
Database: postgres
Username: pguser
Password: pgpass
```

### Metabase

Open your browser to:
```
http://localhost:3000
```

First-time setup takes you through:
1. Admin account creation
2. Data source connection (point to your PostgreSQL)
3. Dataset configuration

## 🔥 Troubleshooting

1. **PostgreSQL won't start**:
   - Check if another instance is using port 15432
   - Run `pgstop` followed by `pgstart`
   - Check log with `tail -f $PGHOST/LOG`

2. **Metabase issues**:
   - Metabase needs Java - check with `java -version`
   - First startup can be slow as it initializes
   - If it crashes, run `mbrestart`

3. **Can't connect to PostgreSQL**:
   - Verify service is running with `flox services status`
   - Check connection details with `echo $PGPORT $PGUSER $PGPASS`
   - Try connecting with explicit parameters: `psql -h 127.0.0.1 -p $PGPORT -U $PGUSER`

## 💻 System Support

Works on:
- macOS (ARM/Intel)
- Linux (ARM/x86)

## 🔍 Power User Tips

- Point Metabase at your PostgreSQL with these details:
  ```
  Host: 127.0.0.1
  Port: 15432
  Database: postgres
  Username: pguser
  Password: pgpass
  ```

- For PostGIS in your database, run:
  ```sql
  CREATE EXTENSION postgis;
  ```

- Edit `manifest.toml` to switch PostgreSQL versions

## About Flox

[Flox](https://flox.dev/docs/) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).

