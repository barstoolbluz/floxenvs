# 🚀 Flox Environment for KIND (Kubernetes in Docker)

This `kind-headless` environment is designed for CI, headless setups, or scripted workflows—i.e., any non-interactive context.

The [`kind`](https://github.com/barstoolbluz/floxenvs/tree/main/kind/) environment is better for local, interactive use—especially when users need help configuring clusters step by step with interactive wizards.

## ✨ Features

- Dynamic environment variable configuration for cluster setup
- Runtime override capabilities for all configuration options
- Automatic cluster creation and management via Flox services
- Automatic directory and configuration management
- Cross-platform compatibility (Linux x86_64 and ARM64, macOS x86_64 and ARM64)
- Default configurations that "just work" with minimal setup
- **No interactive wizards or prompts** - perfect for CI/CD pipelines

## 🧰 Included Tools

The environment includes these essential tools:

- `kind` - Kubernetes in Docker for local cluster testing
- `kubectl` - Kubernetes command-line tool
- `curl` - HTTP client for downloading this `README.md` + other uses
- `bat` - Better `cat` for viewing this `README.md`
- `jq` - JSON processor for Kubernetes resource manipulation
- `coreutils` - GNU `coreutils` # included for macOS/Darwin compatibility

## 🏁 Getting Started

### 📋 Prerequisites

- [Flox](https://flox.dev/get) installed on your system
- Docker installed and running (required by KIND)
- That's it.

### 💻 Installation & Activation

Get started with:

```bash
# Pull the environment
flox pull --copy barstoolbluz/kind-headless

# Activate (without starting services)
cd kind-headless
flox activate

# Or activate and start the cluster immediately
flox activate -s
```

### 🎮 Basic Usage

#### Start the Cluster

```bash
# Start with default configuration
flox activate -s

# The service will:
# 1. Create a KIND cluster named "kind" (default)
# 2. Configure it with 1 control-plane and 1 worker node
# 3. Wait for the cluster to be ready
# 4. Keep running to maintain the cluster
```

#### Check Cluster Status

```bash
# View service logs
flox services logs kind

# Check service status
flox services status

# Use kubectl (inside activated environment)
kubectl cluster-info
kubectl get nodes
kind get clusters
```

#### Stop the Cluster

```bash
# Stop the service (cluster remains)
flox services stop kind

# To delete the cluster completely
kind delete cluster --name kind
```

## ⚙️ Configuration

All configuration is done via environment variables at activation time:

### Runtime Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KIND_CLUSTER_NAME` | `kind` | Name of the KIND cluster |
| `KIND_CONFIG_FILE` | `$FLOX_ENV_CACHE/kind-config/cluster.yaml` | Path to KIND cluster config |
| `KIND_KUBECONFIG` | `$FLOX_ENV_CACHE/kind-data/kubeconfig` | Path to kubeconfig file |
| `KIND_IMAGE` | (latest) | KIND node image (e.g., `kindest/node:v1.27.0`) |

### Configuration Examples

#### Custom Cluster Name

```bash
KIND_CLUSTER_NAME=dev flox activate -s
```

#### Custom Node Image

```bash
KIND_IMAGE=kindest/node:v1.27.0 flox activate -s
```

#### Multiple Clusters

Create a custom config file first:

```bash
# Activate environment
flox activate

# Edit the config file at $KIND_CONFIG_FILE
cat > $KIND_CONFIG_FILE << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

# Start with custom config
flox activate -s
```

Or use a completely different config:

```bash
KIND_CONFIG_FILE=/path/to/my/config.yaml flox activate -s
```

## 🔧 Advanced Usage

### Custom Cluster Configuration

The default cluster config is created at `$KIND_CONFIG_FILE` if it doesn't exist:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
```

Customize this file before starting the service for:
- Multiple control-plane nodes (HA setup)
- Additional worker nodes
- Port mappings
- Volume mounts
- Network configuration

Example multi-node config:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
```

Example with port mappings:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
- role: worker
```

### Using in CI/CD

Perfect for testing Kubernetes manifests in CI:

```yaml
# GitHub Actions example
- name: Setup KIND cluster
  run: |
    flox activate -s -- sleep 5
    kubectl cluster-info
    kubectl apply -f ./manifests/
    kubectl wait --for=condition=Ready pods --all --timeout=300s
```

### Multiple Environments Pattern

Create different configurations for different use cases:

```bash
# Development cluster
KIND_CLUSTER_NAME=dev KIND_CONFIG_FILE=./configs/dev.yaml flox activate -s

# Testing cluster (in another terminal)
KIND_CLUSTER_NAME=test KIND_CONFIG_FILE=./configs/test.yaml flox activate -s

# Production-like cluster
KIND_CLUSTER_NAME=prod KIND_CONFIG_FILE=./configs/prod.yaml flox activate -s
```

## 📝 Common Commands

Inside the activated environment:

```bash
# Show environment info
kind-info

# View this README
readme

# Refresh README from GitHub
readme --refresh

# Cluster operations
kind get clusters
kind get nodes --name kind
kubectl cluster-info
kubectl get all -A

# Clean up
kind delete cluster --name kind
```

## 🐛 Troubleshooting

### Cluster Creation Fails

Check Docker is running:

```bash
docker ps
```

View service logs:

```bash
flox services logs kind
```

### Kubectl Can't Connect

Ensure KUBECONFIG is set:

```bash
export KUBECONFIG=$KIND_KUBECONFIG
kubectl cluster-info
```

### Cluster Already Exists

The service won't recreate an existing cluster. Delete first:

```bash
kind delete cluster --name $KIND_CLUSTER_NAME
flox services restart kind
```

### Check Service Logs

```bash
# View logs in real-time
flox services logs kind

# Check log file directly
cat $KIND_LOG_DIR/service.log
```

## 🔗 Related Environments

- **[kind](https://github.com/barstoolbluz/floxenvs/tree/main/kind/)** - Interactive version with wizards and helpers
- **[k8s-toolkit](https://github.com/barstoolbluz/floxenvs/)** - Traveling toolkit environment for k8s; includes kubectl, k9s, stern, kubectx, etc.

## 📚 Resources

- [KIND Documentation](https://kind.sigs.k8s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Flox Documentation](https://flox.dev/docs)

## 🤝 Contributing

Found a bug or want to improve this environment? Contributions welcome!

## 📄 License

This environment configuration is provided as-is for use with Flox.
