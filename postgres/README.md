# 🐘 A Flox Environment for PostgreSQL with PostGIS

This Flox environment gives you a local PostgreSQL setup that runs in a controlled environment, preventing dependency conflicts without using containers or VMs. Flox doesn't sandbox processes or limit the local user's access.

## ✨ What You Get

- Local PostgreSQL instance—no containers—that doesn't mess with your system
- PostGIS extension for spatial data preinstalled
- Declarative version selection—easily define which version of PostgreSQL you need.
- Port isolation to avoid conflicts with existing PostgreSQL instances
- Setup that takes <30 seconds, not >30 minutes

## 🧰 Tools Included

- `postgresql_16` - Latest stable PostgreSQL release; can customize this to `postgresql_15`, `postgresql_14`, etc.
- `postgis` - Spatial extension for geo work
- `gum` - Powers the clean, elegant, stylish setup UI
- `bat` - Powers the `readme` function

## 🚀 Getting Started

### Prerequisites

- [Flox](https://flox.dev) installed
- That's it. No, really.

### Setup in Two Commands

1. Clone or create a directory
```sh
git clone https://github.com/youruser/postgres-env && cd postgres-env
```

2. Activate and go
```sh
flox activate
```

Want PostgreSQL to start immediately? Just add the `-s` flag:
```sh
flox activate -s
```

### First-Run Configuration

On first activation, you'll get a simple UI that:

1. Lets you set a custom host, port, username, password, and database
2. Uses sane defaults if you just want to get moving
3. Creates an isolated data directory that won't conflict with anything

## 📝 Daily Usage

After setup, these commands are all you need:

```bash
# Start PostgreSQL
pgstart

# Stop PostgreSQL
pgstop

# Restart PostgreSQL (if you change configs)
pgrestart

# Reconfigure from scratch
pgconfigure

# Connect directly to your database
psql
```

## 🔧 Under the Hood

### How It's Set Up

This environment:
1. Creates an isolated data directory in `$FLOX_ENV_CACHE/postgres`
2. Initializes PostgreSQL with UTF-8 encoding and proper permissions
3. Configures a custom port (default: 15432) to avoid conflicts
4. Uses Unix sockets for maximum performance
5. Provides service management through Flox

### Data Persistence

Your database exists at `$FLOX_ENV_CACHE/postgres/data` and persists between environment activations. It's yours - back it up, move it, or nuke it when you're done.

### Configuration Files

- Main config: `$FLOX_ENV_CACHE/postgres.config`
- PostgreSQL config: `$PGDATA/postgresql.conf`

## 🔥 Troubleshooting

Having issues? Try these fixes:

1. **Service won't start**:
   - Check if another PostgreSQL instance is using your configured port
   - Run `pgstop` followed by `pgstart` to reset the service
   - Check log output with `tail -f $PGHOST/LOG`

2. **Connection issues**:
   - Verify your host and port with `echo $PGHOSTADDR:$PGPORT`
   - Try connecting with explicit parameters: `psql -h $PGHOSTADDR -p $PGPORT -U $PGUSER $PGDATABASE`
   - Make sure the service is running with `flox services status`

3. **Total reset**:
   - Run `pgconfigure` to wipe and rebuild your configuration
   - If all else fails, delete `$FLOX_ENV_CACHE/postgres` and reactivate

## 💻 System Support

Runs on:
- macOS (ARM/Intel)
- Linux (ARM/x86)

## 🔍 Power User Tips

- Edit `manifest.toml` to switch PostgreSQL versions
- The default port (15432) avoids conflicts with standard PostgreSQL installations
- To access from external tools, set the host to `0.0.0.0` during configuration
- PostGIS is ready to use - just run `CREATE EXTENSION postgis;` in your database

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
