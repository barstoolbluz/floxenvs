# 🔧 FloxEnvs: Ready-to-Use Dev Environments

A collection of useful Flox environments that just work. Pick an environment, activate it, and get to work—no complex setup, no dependency conflicts, no hermetic isolation in Docker containers or VMs.

## ⚡ What's This?

This repo contains pre-configured [Flox](https://flox.dev/docs) environments for common development stacks. Each environment:

- Runs consistently across macOS and Linux
- Includes smart defaults that don't get in your way
- Offers simple terminal UI for configuration
- Works out of the box—in some cases with a wizard-driven setup experience

## 📦 Available Environments

### CLI Tools
- [**awscli**](./awscli) - AWSCLI2 with local (keyring / encrypted file) auth support
- [**aws-1pass**](./aws-1pass) - AWSCLI2 with 1Password auth support
- [**ghcli**](./ghcli) - GitHub CLI with local (keyring / encrypted file) auth support
- [**xplatform-cli-tools**](./xplatform-cli-tools) - AWSCLI2, GitHub CLI, and Git with 1Password auth support


### Database Environments

- [**postgresql**](./postgres) - PostgreSQL with PostGIS
- [**neo4j**](./neo4j) - Neo4j graph database

### Data Analysis & Visualization

- [**postgres-metabase**](./postgres-metabase) - PostgreSQL + Metabase BI platform
- [**superset**](./superset) - Apache Superset + PostgreSQL for BI / Analytics
- [**harlequin**](./harlequin-postgres) - PostgreSQL + Harlequin terminal SQL IDE

### Data Integration + Data Engineering + General Distributed Compute

- [**spark**](./spark) - Apache Spark with interactive configuration wizard
- [**kafka**](./kafka) - Apache Kafka with interactive configuration wizard
- [**spark-basic**](./spark-basic) - Apache Spark designed for headless use
- [**kafka-basic**](./kafka-basic) - Apache Kafka designed for headless use

### Containers and Kubernetes (K8s)
- [**kind**](./kind) - Kubernetes IN Docker, essential K8s tools, and a KIND auto-configuration wizard
 
### Python Development

- [**python310**](./python310) - Python 3.10 with smart venv management
- [**python311**](./python311) - Python 3.11 with smart venv management
- [**python312**](./python312) - Python 3.12 with smart venv management
- [**python313**](./python313) - Python 3.13 with smart venv management
- [**python-postgres**](./python-postgres) - Python 3.12 with SQLAlchemy + other tools for working with PostgreSQL

## 🚀 Getting Started

### Prerequisites

1. Install [Flox](https://flox.dev/get)
2. Clone this repo
   ```bash
   git clone https://github.com/barstoolbluz/floxenvs
   ```

### Activating an Environment

1. Navigate to the environment you want to use
   ```bash
   cd floxenvs/postgresql
   ```

2. Activate the environment
   ```bash
   flox activate
   ```

3. To start any services in the environment automatically at activation:
   ```bash
   flox activate -s
   ```

## 🔍 How It Works

Each directory contains:

- A `manifest.toml` file in `./.flox/env/` that defines the environment
- A README with specific instructions for that environment

Flox uses declarative configuration to create reproducible environments with:

- Specific package versions
- Built-in environment variables
- Built-in service management capabilities
- Activation hooks that terraform environments or perform other tasks on startup

## 💻 System Requirements

- Works on macOS (Intel/ARM) and Linux (x86/ARM)
- Flox installed
- About 50GB free disk space for all environments

## 🔄 Contributing

Want to add a new environment? Create a PR with:

1. A new directory for your environment
2. A complete Flox environment with `manifest.toml` and `manifest.lock` files located in `.flox/env/`
3. A README following our template

## 🔗 Key Features of Flox

[Flox](https://flox.dev/docs) builds on [Nix](https://github.com/NixOS/nix) to provide:

- **Declarative environments** - Software, variables, services defined in TOML
- **Content-addressed storage** - Multiple package versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **Huge package collection** - Access to 150,000+ packages from Nixpkgs

## 📝 License

MIT

---

