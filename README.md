# 🔧 FloxEnvs: Ready-to-Use Dev Environments

A collection of useful Flox environments that just work. Pick an environment, activate it, and get to work—no complex setup, no dependency conflicts, no hermetic isolation in Docker containers or VMs.

## ⚡ What's This?

This repo contains pre-configured [Flox](https://flox.dev/docs) environments for common development stacks. Each environment:

- Runs consistently across macOS and Linux
- Includes smart defaults that don't get in your way
- Works out of the box with sensible configurations
- Offers both interactive (wizard-driven) and headless (automation-friendly) variants for many tools

## 🎯 Understanding Interactive vs Headless Environments

Many environments in this collection come in **two variants** to support different workflows:

### Interactive Environments
Perfect for local development and learning:
- 🧙 **Interactive configuration wizards** guide you through setup
- 🎨 **Rich terminal UI** using gum for a friendly experience
- 📚 **Great for learning** - explains options as you configure
- 🔧 **Flexible** - easily reconfigure by re-running wizards

**Best for:** Local development, first-time users, learning, exploration

### Headless Environments
Perfect for automation and CI/CD:
- ⚙️ **Environment variable configuration** - no interactive prompts
- 🤖 **Scriptable and automatable** - perfect for CI/CD pipelines
- 🚀 **Zero interaction required** - sensible defaults that just work
- 📦 **Container-friendly** - no TTY required

**Best for:** Docker containers, CI/CD pipelines, automated scripts, production deployments

### How to Choose
Environments marked with ⚡ have both variants available:
- Choose the **base name** (e.g., `postgres`) for interactive wizard-driven setup
- Choose the **-headless variant** (e.g., `postgres-headless`) for automation and scripting

**Example:**
```bash
# Interactive - wizard guides you through configuration
cd postgres && flox activate

# Headless - configure via environment variables
cd postgres-headless && PGPORT=5432 PGDATABASE=mydb flox activate -s
```

## 📦 Available Environments

### CLI & Development Tools
- [**awscli**](./awscli) - AWS CLI v2 with encrypted credential storage (keyring/file)
- [**aws-1pass**](./aws-1pass) - AWS CLI v2 with 1Password integration
- [**ghcli**](./ghcli) - GitHub CLI with encrypted credential storage (keyring/file)
- [**xplatform-cli-tools**](./xplatform-cli-tools) - AWS CLI, GitHub CLI, and Git with 1Password integration

### Databases ⚡
- [**postgres**](./postgres) / [**postgres-headless**](./postgres-headless) - PostgreSQL 16 with PostGIS extension
- [**mysql**](./mysql) / [**mysql-headless**](./mysql-headless) - MySQL 8.0 database
- [**mariadb**](./mariadb) / [**mariadb-headless**](./mariadb-headless) - MariaDB database
- [**redis**](./redis) / [**redis-headless**](./redis-headless) - Redis in-memory data store
- [**neo4j**](./neo4j) / [**neo4j-headless**](./neo4j-headless) - Neo4j graph database

### Data Analytics & BI
- [**postgres-metabase**](./postgres-metabase) - PostgreSQL + Metabase BI platform
- [**harlequin-postgres**](./harlequin-postgres) - PostgreSQL + Harlequin terminal-based SQL IDE

### Distributed Computing & Streaming ⚡
- [**spark**](./spark) / [**spark-headless**](./spark-headless) - Apache Spark cluster computing
- [**kafka**](./kafka) / [**kafka-headless**](./kafka-headless) - Apache Kafka streaming platform

### Container Runtime & Orchestration ⚡
- [**colima-headless**](./colima-headless) - Docker-compatible container runtime (alternative to Docker Desktop)
- [**kind**](./kind) / [**kind-headless**](./kind-headless) - Kubernetes in Docker with essential K8s tools

### Web Servers & Reverse Proxies ⚡
- [**nginx**](./nginx) / [**nginx-headless**](./nginx-headless) - nginx reverse proxy with port/path-based routing and WebSocket support (interactive wizard) or multi-mode server with SSL, rate limiting, caching, and security features (headless)

### CI/CD & Automation
- [**jenkins-headless**](./jenkins-headless) - Jenkins CI/CD server with JCasC and Kubernetes agent support (headless, automation-ready)
- [**jenkins-full-stack**](./jenkins-full-stack) - Production Jenkins with nginx reverse proxy (WebSocket, gzip, SSL, rate limiting)

### Workflow Orchestration
- [**airflow-local-dev**](./airflow-local-dev) - Apache Airflow 3.1.1 with LocalExecutor, CeleryExecutor, and KubernetesExecutor
- [**airflow-k8s-executor**](./airflow-k8s-executor) - Airflow Kubernetes executor with RBAC and pod templates
- [**airflow-stack**](./airflow-stack) - Enterprise Airflow stack with production-grade PostgreSQL, Redis, and Kubernetes
- [**dagster-headless**](./dagster-headless) - Dagster 1.12.0 orchestration platform with optional PostgreSQL support (headless, composable)
- [**n8n**](./n8n) / [**n8n-headless**](./n8n-headless) - n8n workflow automation with PostgreSQL, Redis, and queue mode ⚡
- [**nodered**](./nodered) / [**nodered-headless**](./nodered-headless) - Node-RED low-code programming for IoT and event-driven apps ⚡

### Data Science & Notebooks ⚡
- [**jupyterlab**](./jupyterlab) / [**jupyterlab-headless**](./jupyterlab-headless) - JupyterLab notebook environment

### Python Development
- [**python310**](./python310) - Python 3.10 with smart venv management
- [**python311**](./python311) - Python 3.11 with smart venv management
- [**python312**](./python312) - Python 3.12 with smart venv management
- [**python313**](./python313) - Python 3.13 with smart venv management
- [**python-postgres**](./python-postgres) - Python 3.12 with PostgreSQL tools and SQLAlchemy

### AI & Machine Learning
- [**ollama-headless**](./ollama-headless) - Ollama LLM runtime with CUDA support (headless, composable)
- [**open-webui**](./open-webui) - Web UI for Ollama (includes ollama-headless)
- [**wsl2-ollama**](./wsl2-ollama) - Ollama LLM runtime optimized for WSL2

## 🚀 Getting Started

### Prerequisites

1. Install [Flox](https://flox.dev/get)
2. Clone this repo
   ```bash
   git clone https://github.com/barstoolbluz/floxenvs
   cd floxenvs
   ```

### Quick Start Examples

**For local development (interactive):**
```bash
cd postgres
flox activate
# Follow the interactive wizard to configure PostgreSQL
```

**For CI/CD or automation (headless):**
```bash
cd postgres-headless
PGPORT=5432 PGDATABASE=mydb flox activate -s
# Starts immediately with your configuration
```

**For basic activation:**
```bash
cd python312
flox activate
# Python 3.12 environment ready to use
```

### General Usage

1. Navigate to the environment you want to use
   ```bash
   cd floxenvs/postgres
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
- Activation hooks that configure environments or perform other tasks on startup

## 💻 System Requirements

- Works on macOS (Intel/ARM) and Linux (x86/ARM)
- Flox installed
- About 50GB free disk space for all environments

## 🔄 Contributing

Want to add a new environment? Create a PR with:

1. A new directory for your environment
2. A complete Flox environment with `manifest.toml` and `manifest.lock` files located in `.flox/env/`
3. A README following our template
4. For service-based environments, consider providing both interactive and headless variants

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
