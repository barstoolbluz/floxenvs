# 🔄 A Flox Environment for Neo4j Graph Database Development

A Flox environment for Neo4j graph database development with automated configuration, service management, and browser integration. The environment automates Neo4j installation and setup.

## ✨ Features

- One-step Neo4j config and initialization
- Automatic service management via Flox services
- Smart data directory management
- Persistent configuration across activations
- Cross-platform support (macOS, Linux)
- Intuitive TUI-based setup wizard

## 🧰 Included Tools

The environment packs these essential tools:

- `neo4j` - The powerful graph database platform
- `gum` - Terminal UI toolkit powering the setup wizard
- `bat` - Better `cat` with syntax highlighting

## 🏁 Getting Started

### 📋 Prerequisites

- [Flox](https://flox.dev/get) installed on your system
- Basic understanding of graph databases

### 💻 Installation & Activation

Jump in with:

1. Clone this repo or create a new directory

```sh
git clone https://github.com/youruser/neo4j-env && cd neo4j-env
```

2. Run:

```sh
flox activate
```

This activates the environment with default settings. To start Neo4j automatically during activation:

```sh
flox activate -s
```

### 🧙 Setup Wizard

First-time activation triggers a wizard that:

1. Offers to customize your Neo4j configuration
2. Sets up a data directory for your Neo4j instance
3. Configures network ports for Neo4j's Bolt protocol and HTTP interface
4. Establishes default authentication credentials
5. Creates necessary configuration files

## 📝 Usage

After setup, you have access to these commands:

```bash
# Start Neo4j server
neo4jstart

# Stop Neo4j server
neo4jstop

# Restart Neo4j server
neo4jrestart

# Reconfigure Neo4j settings
neo4jconfigure
```

The Neo4j browser interface is available at:
```
http://localhost:7474
```

Use the credentials you configured during setup to log in (default: username `neo4j`, password `neo4jpass`).

## 🔍 How It Works

### 🔄 Configuration Management

The environment implements a robust configuration strategy:

1. **Default Configuration**: Initial values are provided for quick setup
2. **Customizable Settings**: Easily modify host, ports, credentials, and data directory
3. **Persistence**: Configuration is stored in `$FLOX_ENV_CACHE/neo4j.config`
4. **Directory Structure**: Auto-creates organized data, logs, and configuration directories

### 🚀 Service Integration

The environment uses Flox's built-in service management capabilities to:

1. Run Neo4j as a managed service
2. Handle startup, shutdown, and restart operations
3. Maintain the Neo4j process throughout your development session

## 🔧 Troubleshooting

If you encounter issues:

1. **Startup fails**: 
   - Check that ports aren't already in use
   - Ensure data directory has proper permissions
   - Review logs with `bat $NEO4J_LOGS/neo4j.log`
   
2. **Configuration issues**:
   - Run `neo4jconfigure` to reset and reconfigure Neo4j
   - Verify paths are set correctly for your system

3. **Browser access problems**: 
   - Ensure the HTTP port (default 7474) is not blocked by your system's firewall
   - Verify Neo4j is running with `flox services status`
   - Try accessing via IP address if localhost doesn't work

## 💻 System Compatibility

This works on:
- macOS (ARM64, x86_64)
- Linux (ARM64, x86_64)

## 🔒 Security Considerations

- Default password should be changed in production environments
- Data directory permissions are set to 700 (user-only access)
- Authentication is enabled by default
- Configuration file includes credentials, so protect `$FLOX_ENV_CACHE` directory
- Neo4j service binds to all interfaces (0.0.0.0) by default - restrict this in security-sensitive environments

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
