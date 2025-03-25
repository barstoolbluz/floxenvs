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
- `helm` - Kubernetes package manager
- `gum` - Terminal UI toolkit powering the setup wizard and styling
- `jq` - Command-line JSON processor for API interactions
- `bat` - Used to power the environment's built-in `readme` function
- `curl` - Used to fetch this `README.md`

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
- Detects any existing KIND clusters
- Fires up the cluster creation wizard if no clusters are found
- Drops you into the Flox env with Kubernetes tools ready to go

### 🧙 Cluster Creation Wizard

The environment includes an interactive wizard that:

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
kind_wizard

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

# Manage Kubernetes packages
helm ...
```

## 🔍 How It Works

### 🔄 Cluster Management

The environment implements a streamlined cluster creation process:

1. **Config Generation**: Creates a YAML configuration file for your KIND cluster
2. **Container Runtime Detection**: Automatically checks for Docker or Podman
3. **Version Selection**: Can fetch the latest Kubernetes version or use a specific version
4. **Node Configuration**: Supports multi-node clusters with a control-plane and workers
5. **Cluster Creation**: Launches the cluster with your custom configuration

### 🐚 Shell Integration

The environment includes integration for:
- Bash
- Zsh
- Fish

With helper functions that:
1. Create and manage KIND clusters
2. Provide access to Kubernetes tools
3. Display cluster information and status

### 📊 Kubernetes Interaction

The tools defined in this environment support:
- Deploying applications to Kubernetes
- Managing cluster resources
- Monitoring cluster health
- Installing packages with Helm

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

## 💻 System Compatibility

This works on:
- macOS (ARM64, x86_64)
- Linux (ARM64, x86_64)

## 🔒 Security Considerations

- KIND clusters are intended for development and testing, not production
- Cluster configs are stored as YAML files in your working directory
- Kubernetes credentials are stored in your kubeconfig (typically ~/.kube/config)
- For proper security, follow Kubernetes security best practices even in development

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
