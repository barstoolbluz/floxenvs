# 🐘 A Flox Environment for Harlequin PostgreSQL Development

This Flox environment provides a streamlined setup for PostgreSQL database development using Harlequin, a modern SQL IDE in your terminal. The environment automates configuration, connection management, and provides helpful utilities to make your database workflow smooth and efficient.

## ✨ Features

- Automatic configuration of Harlequin for PostgreSQL connections
- Smart detection of existing PostgreSQL environments
- TUI-based configuration wizard for first-time setup
- Persistent connection configuration storage
- Connection testing and validation utilities
- Database information viewer
- Cross-platform compatibility (macOS, Linux)

## 🧰 Included Tools

The environment packs these essential tools:

- `harlequin` - Modern terminal-based SQL IDE with syntax highlighting
- `harlequin-postgres` - PostgreSQL adapter for Harlequin
- `gum` - Terminal UI toolkit powering the setup wizard and styling
- `glibcLocalesUtf8` - UTF-8 locale support for Linux systems
- `bat` - Better `cat` with syntax highlighting

## 🏁 Getting Started

### 📋 Prerequisites

- PostgreSQL database (local or remote)
- [Flox](https://flox.dev) installed on your system

### 💻 Installation & Activation

Jump in with:

1. Clone this repo or create a new directory

```sh
git clone https://github.com/youruser/harlequin-postgres-env && cd harlequin-postgres-env
```

2. Run:

```sh
flox activate
```

This command:
- Pulls in all dependencies
- Detects any existing PostgreSQL configuration
- Fires up the configuration wizard if needed
- Drops you into the Flox env with Harlequin ready to go

### 🧙 Setup Wizard

First-time activation triggers a wizard that:

1. Looks for existing PostgreSQL configuration in environment variables
2. Checks for a PostgreSQL config file if environment variables aren't found
3. Offers to customize your Harlequin configuration if no valid configuration is found
4. Saves your configuration for future use

## 📝 Usage

After setup, you have access to these commands:

```bash
# Launch Harlequin SQL IDE
harlequin

# Edit your Harlequin configuration
editconf

# Test your PostgreSQL connection
pgtest

# Test your Harlequin database connection
hqtest

# Display database information
dbinfo

# Sync Harlequin settings from PostgreSQL config
hqsync

# Reset Harlequin configuration to defaults
hqreset

# Validate your connection string
hqvalidate
```

## 🔍 How It Works

### 🔄 Configuration Management

The environment implements a multi-tiered configuration strategy:

1. **Existing Environment Variables**: Uses PostgreSQL environment variables if available
2. **PostgreSQL Config File**: Reads from `postgres.config` if present
3. **Harlequin Config File**: Uses `harlequin.env` if it exists
4. **Interactive Configuration**: Prompts for configuration details if no valid config is found

Configuration files are stored in:
- The directory specified by `DEFAULT_PGDIR` environment variable (if set)
- The directory specified by `PGDIR` environment variable (if set)
- The current working directory (fallback)

### 🐚 Shell Integration

The environment includes Bash integration with helper functions that:

1. Launch Harlequin with the correct connection parameters
2. Allow editing configuration files with your preferred editor
3. Provide utilities for testing connections and viewing database information

### 📊 Database Interaction

Harlequin provides a powerful interface for:
- Writing and executing SQL queries
- Exploring database schema
- Viewing query results
- Syntax highlighting for SQL

## 🔧 Troubleshooting

If you encounter issues:

1. **Connection fails**: 
   - Run `pgtest` or `hqtest` to check your connection
   - Verify your PostgreSQL server is running
   - Check your connection details with `hqvalidate`
   
2. **Configuration issues**:
   - Use `editconf` to manually edit your Harlequin configuration
   - Run `hqreset` to reset to default configuration
   - Run `hqsync` to sync from PostgreSQL configuration

3. **Database viewing problems**: 
   - Ensure your database user has appropriate permissions
   - Check that your database exists with `dbinfo`

## 💻 System Compatibility

This works on:
- macOS (ARM64, x86_64)
- Linux (ARM64, x86_64)

## 🔒 Security Considerations

- Harlequin configuration is stored with limited permissions (chmod 600)
- Passwords are masked in the terminal UI
- Connection strings with passwords are never displayed in plaintext
- Be mindful that connection details are stored in configuration files in your environment

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
