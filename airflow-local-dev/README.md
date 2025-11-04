# Apache Airflow Local Development Environment

A flexible Flox environment for Apache Airflow 3.1.1 local development with support for multiple executor modes.

## Features

- **Apache Airflow 3.1.1** with all major providers (Kubernetes, Postgres, Redis, HTTP, SSH)
- **Multiple executor modes**: LocalExecutor, CeleryExecutor, KubernetesExecutor
- **Integrated services**: PostgreSQL and Redis (via FloxHub composition)
- **Auto-initialization**: Database setup and admin user creation on first activation
- **Example DAGs**: Pre-configured examples for each executor type
- **30+ runtime-configurable variables**

## Quick Start

```bash
# Install from FloxHub
flox pull --copy barstoolbluz/airflow-local-dev
cd airflow-local-dev

# Activate with services
flox activate -s

# Access Airflow UI
open http://localhost:8080
# Username: admin
# Password: admin
```

## Executor Modes

### LocalExecutor (Default)
Tasks run locally in parallel processes. Best for development.

```bash
flox activate -s
```

### CeleryExecutor
Tasks distributed across Celery workers. Requires Redis.

```bash
AIRFLOW_EXECUTOR=CeleryExecutor flox activate -s
```

### KubernetesExecutor
Tasks run as Kubernetes pods. Requires Kubernetes cluster and airflow-k8s-executor environment.

```bash
AIRFLOW_EXECUTOR=KubernetesExecutor \
AIRFLOW__KUBERNETES__KUBE_CONFIG=/path/to/kubeconfig \
flox activate -s
```

## Composed Services

This environment automatically includes:

- **postgres-headless** (`barstoolbluz/postgres-headless`) - PostgreSQL 17
  - Default port: 15432
  - Default database: airflow
  - Default user: pguser/pgpass

- **redis-headless** (`barstoolbluz/redis-headless`) - Redis 7.4.1
  - Default port: 16379
  - No password (development mode)

## Runtime Configuration

All variables support `VARIABLE=value flox activate -s` override pattern.

### Executor Selection
```bash
AIRFLOW_EXECUTOR              # LocalExecutor, CeleryExecutor, or KubernetesExecutor
```

### Database Connection
```bash
AIRFLOW_POSTGRES_HOST         # Default: 127.0.0.1
AIRFLOW_POSTGRES_PORT         # Default: 15432
AIRFLOW_POSTGRES_USER         # Default: pguser
AIRFLOW_POSTGRES_PASSWORD     # Default: pgpass
AIRFLOW_POSTGRES_DB           # Default: airflow
```

### Redis Connection (CeleryExecutor)
```bash
AIRFLOW_REDIS_HOST            # Default: 127.0.0.1
AIRFLOW_REDIS_PORT            # Default: 16379
AIRFLOW_REDIS_PASSWORD        # Default: (empty)
```

### Webserver
```bash
AIRFLOW_WEBSERVER_HOST        # Default: 0.0.0.0
AIRFLOW_WEBSERVER_PORT        # Default: 8080
AIRFLOW_WEBSERVER_WORKERS     # Default: 4
```

### Celery Workers
```bash
AIRFLOW_CELERY_WORKERS                    # Default: 1
AIRFLOW__CELERY__WORKER_CONCURRENCY       # Default: 16
```

### Admin User
```bash
AIRFLOW_ADMIN_USER            # Default: admin
AIRFLOW_ADMIN_PASSWORD        # Default: admin
AIRFLOW_ADMIN_EMAIL           # Default: admin@example.com
AIRFLOW_ADMIN_FIRSTNAME       # Default: Admin
AIRFLOW_ADMIN_LASTNAME        # Default: User
```

### Kubernetes (when using KubernetesExecutor)
```bash
AIRFLOW__KUBERNETES__NAMESPACE        # Default: default
AIRFLOW__KUBERNETES__KUBE_CONFIG      # Default: $HOME/.kube/config
AIRFLOW__KUBERNETES__IN_CLUSTER       # Default: False (set True when Airflow runs in K8s)
```

## Example DAGs

Three example DAGs are created automatically in `$FLOX_ENV_CACHE/airflow-dags/`:

1. **example_local_executor** - Simple bash tasks for LocalExecutor
2. **example_celery_executor** - Distributed tasks for CeleryExecutor
3. **example_kubernetes_pod_operator** - Kubernetes pod tasks

## Common Commands

```bash
# Show configuration
airflow-info

# List DAGs
airflow dags list

# Trigger a DAG
airflow dags trigger example_local_executor

# View service status
flox services status

# View service logs
flox services logs airflow-webserver
flox services logs airflow-scheduler

# Restart a service
flox services restart airflow-webserver

# Stop all services
# Exit all active shells (Ctrl+D)
```

## Helper Functions

Available in your shell after activation:

```bash
airflow-info       # Show Airflow configuration
postgres-info      # Show PostgreSQL configuration
redis-info         # Show Redis configuration
```

## Production Use

For production deployments, consider using `airflow-stack` environment which includes:
- CeleryExecutor by default
- Increased connection pools and workers
- Production-grade PostgreSQL and Redis settings
- Kubernetes support out of the box

```bash
flox pull --copy barstoolbluz/airflow-stack
```

## Platform Support

- **Airflow package**: x86_64-linux only
- **Environment**: All platforms (aarch64-darwin, aarch64-linux, x86_64-darwin, x86_64-linux)
- Non-x86_64-linux users can define Airflow via Nix flakes in the manifest

## Architecture

```
airflow-local-dev
├── Apache Airflow 3.1.1 (x86_64-linux)
├── postgres-headless (composed from FloxHub)
└── redis-headless (composed from FloxHub)
```

## Troubleshooting

### Database Connection Errors
```bash
# Check PostgreSQL is running
flox services status postgres

# Test connection
psql -h 127.0.0.1 -p 15432 -U pguser -d airflow
```

### Redis Connection Errors (CeleryExecutor)
```bash
# Check Redis is running
flox services status redis

# Test connection
redis-cli -h 127.0.0.1 -p 16379 ping
```

### Webserver Not Starting
```bash
# Check logs
flox services logs airflow-webserver

# Reinitialize database
rm -rf $FLOX_ENV_CACHE/airflow-data/airflow.db
flox activate  # Will auto-reinitialize
```

## Related Environments

- **airflow-k8s-executor** - Kubernetes executor setup with KIND and RBAC
- **airflow-stack** - Enterprise-grade composition of both environments
- **postgres-headless** - Standalone PostgreSQL 17
- **redis-headless** - Standalone Redis 7.4.1
- **kind-headless** - Kubernetes in Docker for local testing

## License

Apache Airflow is licensed under the Apache License 2.0.
