# 🚢 A Flox Environment for KIND Kubernetes Development

This Flox environment provisions a local Kubernetes cluster using KIND (Kubernetes IN Docker), and includes supporting CLI tools for interacting with the cluster. The environment includes a terminal-based bootstrapping wizard. You use this wizard to define a KIND configuration for Kubernetes, as well as to create a K8s cluster.

## ✨ Features

- Interactive wizard for creating a KIND YAML config + creating custom KIND clusters
- Automatic detection of existing clusters
- Support for specific Kubernetes versions
- Helper commands for common KIND operations
- Cross-platform compatibility (macOS, Linux)

## 🧰 Included Tools

The environment packs these essential tools:

- `kind` - Kubernetes IN Docker for local cluster creation
- `kubectl` - Official Kubernetes command-line tool
- `k9s` - Terminal-based UI for Kubernetes
- `stern` - Multi-pod and container log tailing for Kubernetes
- `helm` - Kubernetes package manager
- `gum` - Terminal UI toolkit powering the setup wizard and styling
- `jq` - Command-line JSON processor for API interactions
- `coreutils` - GNU core utilities for enhanced file and text operations
- `bat` - Used to power the environment's built-in `readme` function
- `curl` - Used to fetch this `README.md` and shell integration scripts

## 🏁 Getting Started

### 📋 Prerequisites

- [Flox](https://flox.dev/get) installed on your system
- Docker or Podman container runtime

OR

- Colima runtime environment (**`flox activate -r flox/colima`**)

### 💻 Installation & Activation

Jump in with:

1. Clone this repo or create a new directory

```sh
git clone https://github.com/barstoolbluz/floxenvs && cd floxenvs/kind
```

2. Run:

```sh
flox activate
```

This command:
- Pulls in all dependencies
- Downloads shell integration scripts from GitHub
- Detects any existing KIND clusters
- Fires up the cluster creation wizard if no clusters are found
- Drops you into the Flox env with Kubernetes tools ready to go

### 🧙 Cluster Creation Wizard

The environment includes an interactive wizard (now called `bootstrap`) that:

1. Checks for a container runtime (Docker/Podman/Colima)
2. Guides you through naming your cluster
3. Lets you select your Kubernetes version
4. Configures the number of worker nodes
5. Creates a KIND configuration file
6. Optionally creates the cluster immediately

## 📝 Usage

After setup, you have access to these commands:

```bash
# Create a new cluster with the interactive wizard
bootstrap

# Create a cluster with an existing config file
create-cluster my-cluster

# Delete a KIND cluster
delete-cluster my-cluster

# List all KIND clusters
kind get clusters

# Manage your Kubernetes cluster
kubectl ...

# Open the K9s terminal UI
k9s

# Tail logs across multiple pods
stern ...

# Manage Kubernetes packages
helm ...

# View this README in the terminal
readme

# Update and view the README
readme --refresh
```

## 🛠️ Working with the Included Tools

### 🖥️ K9s - Terminal UI for Kubernetes

K9s provides a terminal UI to interact with your Kubernetes clusters:

```bash
# Launch K9s with the current context
k9s

# Launch K9s for a specific namespace
k9s -n kube-system

# Launch K9s for a specific context
k9s --context my-context
```

Common workflows with K9s:
- Press `:` to enter command mode (like Vim)
- Type `pod` and press Enter to view pods
- Type `deploy` to view deployments
- Type `svc` to view services
- Type `ns` to switch namespaces
- Press `/` to filter resources
- Press `d` to describe the selected resource
- Press `l` to view logs of the selected pod
- Press `s` to get a shell into the selected pod
- Press `ctrl+d` to delete the selected resource
- Press `?` for help with keyboard shortcuts

### 📊 Stern - Multi-pod Log Tailing

Stern lets you tail logs from multiple pods and containers:

```bash
# Tail logs from all pods with names containing "api"
stern api

# Tail logs from specific containers across all pods
stern --container nginx .

# Tail logs with timestamps
stern --timestamps api

# Tail logs with color-coded output for each pod
stern --color always api

# Tail logs from specific namespace
stern --namespace monitoring api
```

Common use cases:
- Debug distributed applications by viewing logs across multiple services
- Monitor specific components during deployment or testing
- Trace requests across microservices by matching logs with request IDs
- Get real-time feedback during development in a Kubernetes environment

### 📦 Helm - Kubernetes Package Manager

Helm simplifies the deployment of applications and services:

```bash
# List available repositories
helm repo list

# Add a repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# Search for charts
helm search repo nginx

# Install a chart
helm install my-release bitnami/nginx

# List installed releases
helm list

# Upgrade a release
helm upgrade my-release bitnami/nginx --set replicaCount=3

# Uninstall a release
helm uninstall my-release
```

Common workflows:
- Setting up development dependencies (databases, message queues, etc.)
- Deploying applications with consistent configurations
- Managing application lifecycle through upgrades and rollbacks
- Creating custom charts for your applications

## 🔍 How It Works

### 🔄 Shell Integration

The environment dynamically downloads shell integration scripts from GitHub:
- `kind_wizard.bash` for Bash users
- `kind_wizard.zsh` for Zsh users
- `kind_wizard.fish` for Fish users

These scripts provide the `bootstrap` function (renamed from `kind_wizard`) and are automatically sourced in your shell. The shell scripts are stored in `$FLOX_ENV_CACHE` and only downloaded if they don't exist.

### 🔄 Cluster Management

The environment implements a streamlined cluster creation process:

1. **Config Generation**: Creates a YAML configuration file for your KIND cluster
2. **Container Runtime Detection**: Automatically checks for Docker or Podman
3. **Version Selection**: Can fetch the latest Kubernetes version or use a specific version
4. **Node Configuration**: Supports multi-node clusters with a control-plane and workers
5. **Cluster Creation**: Launches the cluster with your custom configuration

### 🐚 Shell Support

The environment includes integration for:
- Bash
- Zsh
- Fish

With helper functions that:
1. Create and manage KIND clusters
2. Provide access to Kubernetes tools
3. Display cluster information and status

### 📖 Integrated Documentation

The `readme` function:
- Downloads this README.md to your environment's cache
- Displays it using `bat` with syntax highlighting and paging
- Can be refreshed with the `--refresh` flag to get the latest version
- Falls back to `cat` if `bat` is not available

### 📊 Kubernetes Development Workflow

This environment is ideal for a local Kubernetes development workflow:

1. Create a local cluster with `bootstrap` or `create-cluster`
2. Deploy applications using `kubectl` or `helm`
3. Monitor deployments with `k9s`
4. Watch application logs with `stern`
5. Iterate on development with fast local feedback cycles
6. Clean up with `delete-cluster` when done

## 🔧 Troubleshooting

If you encounter issues:

1. **Cluster creation fails**: 
   - Verify your container runtime (Docker/Podman) is installed and running
   - Try `docker info` or `podman info` to check
   - For container runtime issues, you can use Flox's Colima environment: `flox activate -s -r flox/colima`
   
2. **Connectivity issues**:
   - Check your `kubectl` context with `kubectl config get-contexts`
   - Ensure you're connecting to the correct cluster
   - Verify network connectivity to your cluster

3. **Resource limitations**: 
   - KIND runs Kubernetes in containers, so resource usage is limited by your Docker/Podman settings
   - Consider adjusting container runtime resource limits for larger clusters

4. **Shell integration issues**:
   - If shell functions aren't available, check internet connectivity
   - The environment tries to download integration scripts from GitHub
   - You can manually download them to `$FLOX_ENV_CACHE` if needed

## 💻 System Compatibility

This works on:
- macOS (ARM64, x86_64)
- Linux (ARM64, x86_64)

## 🔒 Security Considerations

- KIND clusters are intended for development and testing, not production
- Cluster configs are stored as YAML files in your working directory
- Kubernetes credentials are stored in your kubeconfig (typically ~/.kube/config)
- For proper security, follow Kubernetes security best practices even in development
- Shell integration scripts are downloaded from GitHub - review them if you have security concerns

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
