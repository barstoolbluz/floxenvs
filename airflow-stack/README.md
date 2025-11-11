# Apache Airflow Enterprise Stack

A production-ready Flox environment that composes `airflow-local-dev` and `airflow-k8s-executor` with enterprise-grade configuration overrides.

## Features

- **Complete Airflow stack** in one environment
- **CeleryExecutor** enabled by default for distributed task execution
- **Production-grade PostgreSQL** settings (200 max connections, 512MB shared buffers)
- **Production-grade Redis** settings (1GB memory, AOF persistence)
- **Kubernetes support** out of the box for KubernetesPodOperator
- **4 Celery workers** with 32 task concurrency each
- **8 webserver workers** for high availability
- **All services auto-configured** (PostgreSQL, Redis, Airflow, KIND)

## Quick Start

```bash
# Install from FloxHub
flox pull --copy barstoolbluz/airflow-stack
cd airflow-stack

# Activate with all services
flox activate -s

# Access Airflow UI
open http://localhost:8080
# Username: admin
# Password: admin

# View configuration
enterprise-info
```

## What's Included

This environment composes:

### 1. airflow-local-dev
- Apache Airflow 3.1.1
- PostgreSQL 17 (via postgres-headless)
- Redis 7.4.1 (via redis-headless)
- Airflow webserver, scheduler, and workers

### 2. airflow-k8s-executor
- kubectl for cluster management
- KIND cluster for local Kubernetes (via kind-headless)
- Auto-generated RBAC configuration
- Pod templates for worker pods

### 3. Enterprise Overrides
Production-grade configuration applied on top of composed environments.

## Architecture

```
airflow-stack (Enterprise Composition)
│
├── airflow-local-dev (from FloxHub)
│   ├── Apache Airflow 3.1.1
│   ├── postgres-headless (PostgreSQL 17)
│   └── redis-headless (Redis 7.4.1)
│
└── airflow-k8s-executor (from FloxHub)
    ├── kubectl
    └── kind-headless (Kubernetes in Docker)
```

## Enterprise Configuration

### Executor
- **CeleryExecutor** enabled by default
- 4 Celery workers with 32 task concurrency each
- Total capacity: 128 concurrent tasks

### PostgreSQL
```
Database: airflow_prod
Max connections: 200 (vs 100 default)
Shared buffers: 512MB (vs 128MB default)
Work mem: 8MB
Effective cache: 8GB
fsync: on (data safety)
```

### Redis
```
Max memory: 1GB (vs 256MB default)
Persistence: AOF enabled (vs RDB only)
AOF sync: everysec
```

### Webserver
```
Workers: 8 (vs 4 default)
Host: 0.0.0.0
Port: 8080
```

## Runtime Configuration

All base variables from composed environments can be overridden:

### Switch Executor Mode
```bash
# Use LocalExecutor instead
AIRFLOW_EXECUTOR=LocalExecutor flox activate -s

# Use KubernetesExecutor
AIRFLOW_EXECUTOR=KubernetesExecutor flox activate -s
```

### Adjust Worker Scaling
```bash
AIRFLOW_CELERY_WORKERS=8 \
AIRFLOW__CELERY__WORKER_CONCURRENCY=64 \
flox activate -s
```

### Adjust Database Connections
```bash
POSTGRES_MAX_CONNECTIONS=500 \
POSTGRES_SHARED_BUFFERS="1GB" \
flox activate -s
```

### Adjust Redis Memory
```bash
REDIS_MAXMEMORY="2gb" \
flox activate -s
```

### Use Real Kubernetes Cluster
```bash
AIRFLOW_EXECUTOR=KubernetesExecutor \
AIRFLOW_KUBE_CONFIG=~/.kube/config \
AIRFLOW_KUBE_NAMESPACE=airflow-prod \
flox activate -s
```

## Common Commands

```bash
# Show enterprise configuration
enterprise-info

# Show component details
airflow-info           # Airflow configuration
postgres-info          # PostgreSQL settings
redis-info             # Redis settings
k8s-airflow-info       # Kubernetes configuration

# Manage services
flox services status                    # Check all services
flox services logs <service>            # View logs
flox services restart <service>         # Restart service

# Airflow operations
airflow dags list                       # List DAGs
airflow dags trigger <dag_id>           # Trigger DAG
airflow tasks test <dag> <task> <date>  # Test task

# Kubernetes operations (when using K8s)
kubectl get pods -n default             # View worker pods
kubectl logs -n default <pod-name>      # View pod logs
```

## Service Management

All services start automatically with `flox activate -s`:

1. **PostgreSQL** - Database for Airflow metadata
2. **Redis** - Message broker for Celery
3. **KIND Cluster** - Local Kubernetes for testing
4. **Kubernetes RBAC Setup** - ServiceAccount, Role, RoleBinding
5. **Airflow Webserver** - Web UI (port 8080)
6. **Airflow Scheduler** - Task orchestration
7. **Airflow Workers** - Task execution (4 workers)

### Check Service Status
```bash
flox services status
```

### View Service Logs
```bash
flox services logs airflow-webserver
flox services logs airflow-scheduler
flox services logs airflow-worker
flox services logs postgres
flox services logs redis
```

### Restart Services
```bash
# Restart specific service
flox services restart airflow-scheduler

# Restart all services
flox services restart
```

## Production Deployment Scenarios

### 1. Development/Testing (Default)
Uses local KIND cluster and localhost services:
```bash
flox activate -s
```

### 2. Production with GKE
```bash
gcloud container clusters get-credentials prod-cluster --zone us-central1-a

AIRFLOW_EXECUTOR=CeleryExecutor \
AIRFLOW_KUBE_CONFIG=~/.kube/config \
AIRFLOW_KUBE_NAMESPACE=airflow-prod \
POSTGRES_MAX_CONNECTIONS=500 \
REDIS_MAXMEMORY="4gb" \
AIRFLOW_CELERY_WORKERS=8 \
flox activate -s
```

### 3. Production with EKS
```bash
aws eks update-kubeconfig --name prod-cluster --region us-east-1

AIRFLOW_EXECUTOR=CeleryExecutor \
AIRFLOW_KUBE_CONFIG=~/.kube/config \
AIRFLOW_KUBE_NAMESPACE=airflow-prod \
POSTGRES_MAX_CONNECTIONS=500 \
REDIS_MAXMEMORY="4gb" \
AIRFLOW_CELERY_WORKERS=8 \
flox activate -s
```

### 4. Kubernetes-Native Deployment
Airflow running inside Kubernetes:
```bash
AIRFLOW_EXECUTOR=KubernetesExecutor \
AIRFLOW_KUBE_IN_CLUSTER=True \
AIRFLOW_KUBE_NAMESPACE=airflow \
POSTGRES_MAX_CONNECTIONS=500 \
flox activate -s
```

### 5. Hybrid: Celery + Kubernetes
Use CeleryExecutor for regular tasks, KubernetesPodOperator for specialized workloads:
```bash
AIRFLOW_EXECUTOR=CeleryExecutor \
AIRFLOW_KUBE_CONFIG=~/.kube/config \
AIRFLOW_CELERY_WORKERS=4 \
flox activate -s
```

## Kubernetes Uncontained: Enterprise Deployment

Deploy the complete enterprise stack to Kubernetes using the imageless container pattern.

### Architecture

**Three Separate Deployments:**
1. Scheduler (1-2 replicas for HA)
2. Webserver (2+ replicas for load balancing)
3. Workers (4+ replicas for task execution)

**External Services:**
- PostgreSQL (managed: CloudSQL/RDS/Azure Database)
- Redis (managed: ElastiCache/Cloud Memorystore)

### Complete Example

```yaml
---
# Scheduler
apiVersion: apps/v1
kind: Deployment
metadata:
  name: airflow-scheduler
  namespace: airflow-prod
spec:
  replicas: 2
  selector:
    matchLabels:
      app: airflow
      component: scheduler
  template:
    metadata:
      labels:
        app: airflow
        component: scheduler
      annotations:
        flox.dev/environment: "barstoolbluz/airflow-stack"
    spec:
      runtimeClassName: flox
      containers:
      - name: scheduler
        image: flox/empty:1.0.0
        command: ["airflow", "scheduler"]
        env:
        - name: AIRFLOW_EXECUTOR
          value: "CeleryExecutor"
        - name: AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: database-url
        - name: AIRFLOW__CELERY__BROKER_URL
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: redis-url

---
# Webserver
apiVersion: apps/v1
kind: Deployment
metadata:
  name: airflow-webserver
  namespace: airflow-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: airflow
      component: webserver
  template:
    metadata:
      labels:
        app: airflow
        component: webserver
      annotations:
        flox.dev/environment: "barstoolbluz/airflow-stack"
    spec:
      runtimeClassName: flox
      containers:
      - name: webserver
        image: flox/empty:1.0.0
        command: ["airflow", "webserver", "--port", "8080"]
        ports:
        - containerPort: 8080
        env:
        - name: AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: database-url
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
          limits:
            cpu: "2000m"
            memory: "2Gi"

---
# Workers
apiVersion: apps/v1
kind: Deployment
metadata:
  name: airflow-worker
  namespace: airflow-prod
spec:
  replicas: 4
  selector:
    matchLabels:
      app: airflow
      component: worker
  template:
    metadata:
      labels:
        app: airflow
        component: worker
      annotations:
        flox.dev/environment: "barstoolbluz/airflow-stack"
    spec:
      runtimeClassName: flox
      containers:
      - name: worker
        image: flox/empty:1.0.0
        command: ["airflow", "celery", "worker"]
        env:
        - name: AIRFLOW__CELERY__BROKER_URL
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: redis-url
        - name: AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
          valueFrom:
            secretKeyRef:
              name: airflow-secrets
              key: database-url
        resources:
          requests:
            cpu: "500m"
            memory: "2Gi"
          limits:
            cpu: "2000m"
            memory: "4Gi"

---
# Webserver Service
apiVersion: v1
kind: Service
metadata:
  name: airflow-webserver
  namespace: airflow-prod
spec:
  selector:
    app: airflow
    component: webserver
  ports:
  - port: 8080
    targetPort: 8080
```

### Enterprise Configuration Applied

The `airflow-stack` environment automatically applies:
- CeleryExecutor (vs LocalExecutor)
- Production database settings (200 connections, 512MB buffers)
- Production Redis settings (1GB memory, AOF persistence)
- 4 workers with 32 task concurrency each

These are **configuration defaults** - in K8s you override via env vars.

### Important Notes

1. **Separate postgres/redis deployments:** This environment composes postgres-headless and redis-headless for **local development**. In Kubernetes, use managed services.

2. **DAGs:** Not included in environment. Mount via ConfigMap or use git-sync.

3. **Updates:** To update Airflow version, update the FloxHub environment and change the `flox.dev/environment` annotation.

### Benefits

- ✅ CVE Response: Update environment, push, update reference - no image rebuilds
- ✅ Compliance: SBOMs generated from dependency graph
- ✅ Auditability: Hash-addressed packages provide tamper-evident provenance
- ✅ Cost: No registry storage/egress costs, node-local caching
- ✅ Speed: First pod pull downloads packages, subsequent pods reuse node cache

## Example DAGs

Three example DAGs are included in `$FLOX_ENV_CACHE/airflow-dags/`:

### 1. example_local_executor
Simple bash tasks for LocalExecutor testing.

### 2. example_celery_executor
Demonstrates distributed task execution with Celery:
- Multiple parallel tasks
- Task dependencies
- Worker routing

### 3. example_kubernetes_pod_operator
Kubernetes pod-based tasks:
- Pod creation and management
- Resource limits
- Custom container images

## Helper Functions

All helper functions from composed environments are available:

```bash
enterprise-info        # Enterprise stack overview (from airflow-stack)
airflow-info          # Airflow configuration (from airflow-local-dev)
postgres-info         # PostgreSQL settings (from postgres-headless)
redis-info            # Redis settings (from redis-headless)
k8s-airflow-info      # Kubernetes configuration (from airflow-k8s-executor)
kind-info             # KIND cluster info (from kind-headless)
```

## Scaling Guidelines

### Vertical Scaling (Single Environment)

#### More Workers
```bash
AIRFLOW_CELERY_WORKERS=8 flox activate -s
```

#### More Task Concurrency
```bash
AIRFLOW__CELERY__WORKER_CONCURRENCY=64 flox activate -s
```

#### More Database Connections
```bash
POSTGRES_MAX_CONNECTIONS=500 \
POSTGRES_SHARED_BUFFERS="1GB" \
flox activate -s
```

### Horizontal Scaling (Multiple Environments)

1. **Separate Scheduler and Workers**
   - Run scheduler in one environment
   - Run workers in separate environments
   - All connect to same PostgreSQL and Redis

2. **Dedicated Worker Pools**
   - Create multiple environments with different worker configurations
   - Use Celery queues to route tasks

## Monitoring

### View All Service Logs
```bash
# Terminal 1: Webserver
flox services logs airflow-webserver -f

# Terminal 2: Scheduler
flox services logs airflow-scheduler -f

# Terminal 3: Workers
flox services logs airflow-worker -f
```

### Check Task Execution
```bash
# View task instances
airflow tasks states-for-dag-run <dag_id> <run_id>

# View task logs
airflow tasks log <dag_id> <task_id> <execution_date>
```

### Monitor Kubernetes Pods
```bash
# Watch worker pods
kubectl get pods -n $AIRFLOW_KUBE_NAMESPACE -w

# Pod events
kubectl describe pod -n $AIRFLOW_KUBE_NAMESPACE <pod-name>
```

## Platform Support

- **Airflow package**: x86_64-linux only
- **All other packages**: All platforms
- **Environment**: All platforms (aarch64-darwin, aarch64-linux, x86_64-darwin, x86_64-linux)
- Non-x86_64-linux users can define Airflow via Nix flakes in the manifest

## Troubleshooting

### Services Not Starting
```bash
# Check service status
flox services status

# View specific service logs
flox services logs <service-name>

# Restart failed service
flox services restart <service-name>
```

### Database Connection Issues
```bash
# Verify PostgreSQL
psql -h 127.0.0.1 -p 15432 -U pguser -d airflow_prod

# Check max connections
postgres-info
```

### Redis Connection Issues
```bash
# Verify Redis
redis-cli -h 127.0.0.1 -p 16379 ping

# Check memory
redis-info
```

### Worker Tasks Not Executing
```bash
# Check Celery workers
airflow celery inspect active

# View worker logs
flox services logs airflow-worker

# Check Redis broker
redis-cli -h 127.0.0.1 -p 16379 info
```

### Kubernetes Pods Not Creating
```bash
# Check RBAC
kubectl get serviceaccount,role,rolebinding -n $AIRFLOW_KUBE_NAMESPACE

# Verify cluster access
kubectl cluster-info
kubectl get nodes

# View Airflow scheduler logs
flox services logs airflow-scheduler
```

## Security Considerations

### Production Checklist

- [ ] Change admin password: Set `AIRFLOW_ADMIN_PASSWORD`
- [ ] Set PostgreSQL password: Set `AIRFLOW_POSTGRES_PASSWORD` and `POSTGRES_PASSWORD`
- [ ] Set Redis password: Set `AIRFLOW_REDIS_PASSWORD` and `REDIS_PASSWORD`
- [ ] Use TLS for webserver: Configure reverse proxy (nginx/traefik)
- [ ] Restrict webserver host: Set `AIRFLOW_WEBSERVER_HOST=127.0.0.1`
- [ ] Enable Airflow RBAC: Configure users and roles
- [ ] Review Kubernetes RBAC: Adjust permissions in `$AIRFLOW_KUBE_RBAC_CONFIG`
- [ ] Use secrets management: Vault, AWS Secrets Manager, etc.
- [ ] Enable audit logging: Configure Airflow audit logs

## Performance Tuning

### Database
```bash
POSTGRES_MAX_CONNECTIONS=500
POSTGRES_SHARED_BUFFERS="2GB"
POSTGRES_WORK_MEM="16MB"
POSTGRES_EFFECTIVE_CACHE_SIZE="16GB"
```

### Redis
```bash
REDIS_MAXMEMORY="4gb"
REDIS_MAXMEMORY_POLICY="allkeys-lru"
```

### Celery
```bash
AIRFLOW_CELERY_WORKERS=8
AIRFLOW__CELERY__WORKER_CONCURRENCY=64
AIRFLOW__CELERY__WORKER_PREFETCH_MULTIPLIER=4
```

### Webserver
```bash
AIRFLOW_WEBSERVER_WORKERS=16
```

## Comparison with Base Environments

| Configuration | airflow-local-dev | airflow-stack |
|--------------|-------------------|---------------|
| Executor | LocalExecutor | CeleryExecutor |
| Postgres Max Conn | 100 | 200 |
| Postgres Buffers | 128MB | 512MB |
| Redis Memory | 256MB | 1GB |
| Redis Persistence | RDB only | AOF enabled |
| Celery Workers | 1 | 4 |
| Worker Concurrency | 16 | 32 |
| Webserver Workers | 4 | 8 |
| Kubernetes | Optional | Included |

## Related Environments

- **airflow-local-dev** - Base Airflow environment (LocalExecutor)
- **airflow-k8s-executor** - Kubernetes executor configuration
- **postgres-headless** - Standalone PostgreSQL 17
- **redis-headless** - Standalone Redis 7.4.1
- **kind-headless** - Standalone KIND cluster

## Migration from airflow-local-dev

If you're already using `airflow-local-dev`:

1. Your DAGs are portable - copy from old to new `$FLOX_ENV_CACHE/airflow-dags/`
2. Database schema is compatible - export/import if needed
3. Configuration variables are the same - use same overrides
4. Services are additive - no breaking changes

## License

Apache Airflow is licensed under the Apache License 2.0.

## Support

For issues with:
- **Flox environments**: https://github.com/flox/flox
- **Apache Airflow**: https://github.com/apache/airflow
- **This environment**: https://github.com/barstoolbluz (if applicable)
