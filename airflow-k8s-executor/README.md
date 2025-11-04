# Apache Airflow Kubernetes Executor Environment

A Flox environment for configuring Apache Airflow to run tasks as Kubernetes pods, with built-in KIND support for local testing.

## Features

- **Apache Airflow 3.1.1** with Kubernetes provider
- **kubectl** for cluster management
- **KIND integration** for local Kubernetes testing (via FloxHub composition)
- **Auto-generated RBAC** (ServiceAccount, Role, RoleBinding)
- **Auto-generated pod templates** with configurable resources
- **Supports any Kubernetes cluster**: KIND, GKE, EKS, AKS, self-hosted

## Quick Start

### Local Testing with KIND

```bash
# Install from FloxHub
flox pull --copy barstoolbluz/airflow-k8s-executor
cd airflow-k8s-executor

# Activate with services (starts KIND cluster)
flox activate -s

# Apply RBAC configuration
kubectl apply -f $AIRFLOW_KUBE_RBAC_CONFIG

# Verify setup
k8s-airflow-info
kubectl get serviceaccount,role,rolebinding -n default
```

### With Real Kubernetes Cluster

```bash
# Point to your kubeconfig
AIRFLOW_KUBE_CONFIG=~/.kube/config flox activate -s

# Apply RBAC to your cluster
kubectl apply -f $AIRFLOW_KUBE_RBAC_CONFIG

# Use with airflow-local-dev for complete setup
```

## Kubernetes Cluster Options

### 1. Local KIND Cluster (Default)

Uses the included KIND environment for local testing:

```bash
flox activate -s
# KIND cluster automatically configured
```

### 2. Google Kubernetes Engine (GKE)

```bash
gcloud container clusters get-credentials my-cluster --zone us-central1-a

AIRFLOW_KUBE_CONFIG=~/.kube/config \
AIRFLOW_KUBE_NAMESPACE=airflow-prod \
flox activate -s
```

### 3. Amazon EKS

```bash
aws eks update-kubeconfig --name my-cluster --region us-east-1

AIRFLOW_KUBE_CONFIG=~/.kube/config \
AIRFLOW_KUBE_NAMESPACE=airflow-prod \
flox activate -s
```

### 4. Azure AKS

```bash
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

AIRFLOW_KUBE_CONFIG=~/.kube/config \
AIRFLOW_KUBE_NAMESPACE=airflow-prod \
flox activate -s
```

### 5. Self-Hosted Kubernetes

```bash
AIRFLOW_KUBE_CONFIG=/etc/kubernetes/admin.conf \
AIRFLOW_KUBE_NAMESPACE=airflow \
flox activate -s
```

### 6. In-Cluster Configuration

When running Airflow itself inside Kubernetes:

```bash
AIRFLOW_KUBE_IN_CLUSTER=True \
AIRFLOW_KUBE_NAMESPACE=airflow \
flox activate -s
```

## Runtime Configuration

All variables support `VARIABLE=value flox activate -s` override pattern.

### Kubernetes Connection
```bash
AIRFLOW_KUBE_NAMESPACE                     # Default: default
AIRFLOW_KUBE_CONFIG                        # Default: $KIND_KUBECONFIG
AIRFLOW_KUBE_IN_CLUSTER                    # Default: False
```

### Pod Configuration
```bash
AIRFLOW_KUBE_IMAGE_PULL_POLICY             # Default: IfNotPresent
AIRFLOW_KUBE_DELETE_WORKER_PODS            # Default: True
AIRFLOW_KUBE_DELETE_WORKER_PODS_ON_FAILURE # Default: False
AIRFLOW_KUBE_WORKER_SERVICE_ACCOUNT        # Default: airflow
```

### Resource Limits
```bash
AIRFLOW_KUBE_WORKER_CPU_REQUEST            # Default: 100m
AIRFLOW_KUBE_WORKER_CPU_LIMIT              # Default: 1000m
AIRFLOW_KUBE_WORKER_MEM_REQUEST            # Default: 512Mi
AIRFLOW_KUBE_WORKER_MEM_LIMIT              # Default: 2Gi
```

## Generated Configuration Files

### RBAC Configuration
Located at: `$AIRFLOW_KUBE_RBAC_CONFIG` (or `$FLOX_ENV_CACHE/k8s-config/rbac.yaml`)

Creates:
- **ServiceAccount**: `airflow` in specified namespace
- **Role**: `airflow-role` with permissions for pods, logs, configmaps, secrets
- **RoleBinding**: Binds role to service account

Apply with:
```bash
kubectl apply -f $AIRFLOW_KUBE_RBAC_CONFIG
```

### Pod Template
Located at: `$AIRFLOW_KUBE_POD_TEMPLATE` (or `$FLOX_ENV_CACHE/k8s-templates/worker-pod-template.yaml`)

Defines:
- Base container image: `apache/airflow:3.1.1`
- Resource requests and limits (configurable)
- Service account reference
- Restart policy: Never

Reference in Airflow configuration or customize as needed.

## Integration with airflow-local-dev

This environment is designed to be composed with `airflow-local-dev`:

### Option 1: Use airflow-stack (Recommended)
```bash
flox pull --copy barstoolbluz/airflow-stack
cd airflow-stack
flox activate -s
```

The `airflow-stack` environment includes both `airflow-local-dev` and `airflow-k8s-executor`.

### Option 2: Manual Composition
In your own manifest.toml:
```toml
[include]
environments = [
  { remote = "barstoolbluz/airflow-local-dev" },
  { remote = "barstoolbluz/airflow-k8s-executor" },
]

[hook]
on-activate = '''
export AIRFLOW_EXECUTOR="KubernetesExecutor"
'''
```

## Common Commands

```bash
# Show configuration
k8s-airflow-info

# Test pod creation
k8s-test-pod

# Check RBAC resources
kubectl get serviceaccount,role,rolebinding -n $AIRFLOW_KUBE_NAMESPACE

# View pod template
cat $AIRFLOW_KUBE_POD_TEMPLATE

# Monitor worker pods
kubectl get pods -n $AIRFLOW_KUBE_NAMESPACE -w

# View worker logs
kubectl logs -n $AIRFLOW_KUBE_NAMESPACE -l app=airflow

# KIND cluster status (if using KIND)
kind-info
kubectl cluster-info
```

## Helper Functions

Available in your shell after activation:

```bash
k8s-airflow-info   # Show Kubernetes configuration for Airflow
k8s-test-pod       # Test pod creation with current configuration
kind-info          # Show KIND cluster info (when using KIND)
```

## Production Recommendations

### Namespace Isolation
```bash
AIRFLOW_KUBE_NAMESPACE=airflow-prod flox activate -s
```

### Increase Resource Limits
```bash
AIRFLOW_KUBE_WORKER_CPU_REQUEST=500m \
AIRFLOW_KUBE_WORKER_CPU_LIMIT=2000m \
AIRFLOW_KUBE_WORKER_MEM_REQUEST=1Gi \
AIRFLOW_KUBE_WORKER_MEM_LIMIT=4Gi \
flox activate -s
```

### Custom Container Image
Edit `$AIRFLOW_KUBE_POD_TEMPLATE` to specify your custom Airflow image with additional dependencies.

### Pod Security
Consider adding:
- Security contexts in pod template
- Network policies for pod-to-pod communication
- Resource quotas in namespace
- Pod disruption budgets

## Composed Services

This environment automatically includes:

- **kind-headless** (`barstoolbluz/kind-headless`) - Kubernetes in Docker
  - Cluster name: kind
  - 1 control-plane node, 1 worker node
  - Auto-configured kubeconfig

## Platform Support

- **Airflow package**: x86_64-linux only
- **kubectl**: All platforms
- **Environment**: All platforms (aarch64-darwin, aarch64-linux, x86_64-darwin, x86_64-linux)
- Non-x86_64-linux users can define Airflow via Nix flakes in the manifest

## Architecture

```
airflow-k8s-executor
├── Apache Airflow 3.1.1 (x86_64-linux)
├── kubectl (all platforms)
└── kind-headless (composed from FloxHub)
```

## Example: Complete Kubernetes Setup

```bash
# 1. Activate environment with services
flox activate -s

# 2. Wait for KIND cluster to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# 3. Apply RBAC configuration
kubectl apply -f $AIRFLOW_KUBE_RBAC_CONFIG

# 4. Verify RBAC
kubectl get serviceaccount airflow -n default
kubectl get role airflow-role -n default
kubectl get rolebinding airflow-role-binding -n default

# 5. Test pod creation
k8s-test-pod

# 6. Use with Airflow (in another terminal)
cd ../airflow-local-dev
AIRFLOW_EXECUTOR=KubernetesExecutor \
AIRFLOW_KUBE_CONFIG=$KIND_KUBECONFIG \
flox activate -s
```

## Troubleshooting

### KIND Cluster Not Starting
```bash
# Check KIND service
flox services status kind-cluster

# View logs
flox services logs kind-cluster

# Manually start cluster
kind create cluster --config $KIND_CLUSTER_CONFIG
```

### RBAC Permissions Issues
```bash
# Verify service account exists
kubectl get serviceaccount airflow -n $AIRFLOW_KUBE_NAMESPACE

# Check role bindings
kubectl get rolebinding airflow-role-binding -n $AIRFLOW_KUBE_NAMESPACE -o yaml

# Recreate RBAC
kubectl delete -f $AIRFLOW_KUBE_RBAC_CONFIG
kubectl apply -f $AIRFLOW_KUBE_RBAC_CONFIG
```

### Worker Pods Not Starting
```bash
# Check pod events
kubectl describe pod -n $AIRFLOW_KUBE_NAMESPACE <pod-name>

# Check image pull
kubectl get pods -n $AIRFLOW_KUBE_NAMESPACE

# Verify resource availability
kubectl describe nodes
```

## Related Environments

- **airflow-local-dev** - Airflow with LocalExecutor/CeleryExecutor support
- **airflow-stack** - Enterprise composition with production settings
- **kind-headless** - Standalone KIND cluster
- **postgres-headless** - PostgreSQL for Airflow metadata
- **redis-headless** - Redis for Celery workers

## License

Apache Airflow is licensed under the Apache License 2.0.
