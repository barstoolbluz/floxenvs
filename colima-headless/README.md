# Colima - Container Runtime Environment

Cross-platform Docker-compatible container runtime using Colima, with full runtime configuration support.

## Features

- **Runtime-configurable** - Override any setting via environment variables
- **Cross-platform** - Works on Linux (x86_64, aarch64) and macOS (x86_64, Apple Silicon)
- **Auto-detection** - KVM support auto-detected on Linux
- **Multiple runtimes** - Docker (default) or containerd
- **Profile support** - Run multiple Colima instances
- **Service integration** - Start/stop via Flox services

## Quick Start

```bash
# Clone and activate with defaults
git clone https://github.com/barstoolbluz/colima.git
cd colima
flox activate

# Start Colima service
flox activate -s

# Test Docker
docker run hello-world
```

## Runtime Configuration

All settings can be overridden at activation time:

### Default Configuration

```bash
flox activate
# CPU: 2 cores
# Memory: 2GB
# Disk: 60GB
# Runtime: docker
# Profile: default
```

### Custom Configuration

```bash
# High-performance setup
COLIMA_CPU=4 COLIMA_MEMORY=8 flox activate -s

# Containerd runtime
COLIMA_RUNTIME=containerd flox activate -s

# Multiple profiles
COLIMA_PROFILE=dev COLIMA_CPU=2 COLIMA_MEMORY=4 flox activate -s
COLIMA_PROFILE=prod COLIMA_CPU=8 COLIMA_MEMORY=16 flox activate -s

# ARM architecture
COLIMA_ARCH=aarch64 flox activate -s
```

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COLIMA_CPU` | `2` | Number of CPU cores |
| `COLIMA_MEMORY` | `2` | Memory in GB |
| `COLIMA_DISK` | `60` | Disk size in GB |
| `COLIMA_ARCH` | `x86_64` | Architecture (x86_64 or aarch64) |
| `COLIMA_RUNTIME` | `docker` | Container runtime (docker or containerd) |
| `COLIMA_PROFILE` | `default` | Profile name for multiple instances |
| `COLIMA_CPU_TYPE` | (auto) | CPU type (auto-detected: host with KVM, qemu64 otherwise) |
| `COLIMA_KUBERNETES` | `false` | Enable Kubernetes cluster in Colima VM |

## Usage Examples

### Development Environment

```bash
# Lightweight dev setup
COLIMA_CPU=2 COLIMA_MEMORY=4 COLIMA_PROFILE=dev flox activate -s

# Use Docker
docker build -t myapp .
docker run myapp
```

### Production Testing

```bash
# Higher resources for production testing
COLIMA_CPU=8 COLIMA_MEMORY=16 COLIMA_PROFILE=prod flox activate -s

# Use containerd
COLIMA_RUNTIME=containerd flox activate -s
```

### Kubernetes Testing

```bash
# Enable Kubernetes at activation
COLIMA_CPU=4 COLIMA_MEMORY=8 COLIMA_KUBERNETES=true flox activate -s

# Use kubectl (kubeconfig is automatically set)
kubectl get nodes
kubectl cluster-info
```

## Commands

### Environment Commands

```bash
# Show configuration
colima-info

# Start Colima service
flox activate -s

# Check service status
flox services status

# View logs
flox services logs colima

# Stop service
flox services stop colima
# or exit the shell
```

### Colima Commands

```bash
# Check Colima status
colima status

# List profiles
colima list

# SSH into VM
colima ssh

# Delete profile
colima delete <profile>
```

### Docker Commands

```bash
# Standard Docker commands work
docker ps
docker images
docker build -t myimage .
docker run myimage
docker compose up
```

## Platform-Specific Notes

### Linux

- Auto-detects KVM support
- Uses `host` CPU type if KVM available (best performance)
- Falls back to `qemu64` if no KVM (slower but compatible)
- Requires user in `kvm` group for best performance

### macOS

- Uses Apple Virtualization Framework on macOS 13+
- Can use VZ or QEMU
- ARM Macs: Set `COLIMA_ARCH=aarch64` for native performance

## Troubleshooting

### Colima won't start

Check if another VM is running:
```bash
colima list
colima delete default  # Delete existing instance
flox activate -s  # Restart
```

### Docker commands fail

Verify Docker socket:
```bash
echo $DOCKER_HOST
# Should show: unix://$HOME/.colima/<profile>/docker.sock

# Test connection
docker ps
```

### Low performance on Linux

Ensure KVM is available:
```bash
# Check KVM access
ls -la /dev/kvm

# Add user to kvm group
sudo usermod -aG kvm $USER
# Log out and back in
```

### Multiple profiles conflict

Each profile needs unique resources:
```bash
# Stop other profiles first
colima list
colima stop <other-profile>

# Start desired profile
COLIMA_PROFILE=dev flox activate -s
```

## Advanced Usage

### Custom VM Configuration

Create custom config in `~/.colima/<profile>/colima.yaml`:

```yaml
cpu: 4
memory: 8
disk: 100
runtime: docker
kubernetes:
  enabled: true
  version: v1.28.0
```

Then activate with that profile:
```bash
COLIMA_PROFILE=custom flox activate -s
```

### Integration with KIND

Colima works great with KIND (Kubernetes in Docker):

```bash
# Start Colima
flox activate -s

# Install and use KIND
kind create cluster
kubectl cluster-info
```

### Using with Docker Compose

```bash
# Start Colima
flox activate -s

# Use Docker Compose normally
docker compose up -d
docker compose logs
```

## Comparison with Docker Desktop

| Feature | Colima | Docker Desktop |
|---------|--------|----------------|
| **License** | Free, Apache 2.0 | Free for personal, paid for enterprise |
| **Resources** | Lightweight | Heavier |
| **Performance** | Fast (KVM on Linux) | Good |
| **Configuration** | Flexible, CLI-based | GUI-based |
| **Kubernetes** | Included | Included |
| **Cost** | Free | Free/Paid |

## Related Environments

- **colima-wsl** - WSL2-specific Colima configuration with additional tooling
- **kind-headless** - Kubernetes in Docker for local testing

## Contributing

Contributions welcome! This environment uses runtime environment variables for configuration following the pattern:

```bash
export VAR="${VAR:-default}"
```

This allows users to override at activation time while providing sensible defaults.

## License

This Flox environment configuration is provided as-is.

Colima itself is licensed under the Apache License 2.0.

## Links

- **Colima**: https://github.com/abiosoft/colima
- **Docker**: https://www.docker.com/
- **Flox**: https://flox.dev/
