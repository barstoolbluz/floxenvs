# Redis Headless Environment

A fully-automated Redis environment for Flox configured entirely via environment variables. Perfect for CI/CD, containerization, and reproducible deployments.

## Features

- **Zero Interaction**: Fully automated setup with no prompts
- **Environment Variable Configuration**: All settings via env vars
- **Production Ready**: Comprehensive configuration options
- **Multiple Persistence Options**: RDB snapshots and AOF logging
- **Memory Management**: Configurable limits and eviction policies
- **Performance Tuning**: Connection pooling, timeouts, and more
- **Monitoring Built-in**: Slow log and latency monitoring

## Quick Start

```bash
# Default configuration
cd redis-headless
flox activate -s

# Connect
redis-cli -p 16379

# With custom settings
REDIS_PORT=6380 REDIS_PASSWORD=secret flox activate -s

# Show configuration
redis-info
```

## Configuration Variables

### Connection (3 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_HOST` | `127.0.0.1` | Bind address (use `0.0.0.0` for all interfaces) |
| `REDIS_PORT` | `16379` | Port number |
| `REDIS_PASSWORD` | (none) | Authentication password (empty = no auth) |

### Memory Management (3 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_MAXMEMORY` | `256mb` | Maximum memory limit |
| `REDIS_MAXMEMORY_POLICY` | `noeviction` | Eviction policy when max memory reached |
| `REDIS_MAXMEMORY_SAMPLES` | `5` | Number of samples for LRU/LFU algorithms |

**Eviction Policies**:
- `noeviction`: Return errors when memory limit reached (default)
- `allkeys-lru`: Evict least recently used keys
- `allkeys-lfu`: Evict least frequently used keys
- `volatile-lru`: Evict LRU among keys with expire set
- `volatile-lfu`: Evict LFU among keys with expire set
- `volatile-ttl`: Evict keys with nearest expire time
- `allkeys-random`: Evict random keys
- `volatile-random`: Evict random keys with expire set

### Persistence - RDB Snapshots (6 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_SAVE_RDB` | `yes` | Enable RDB snapshots |
| `REDIS_SAVE_900` | `1` | Save if 1+ changes in 900s (15min) |
| `REDIS_SAVE_300` | `10` | Save if 10+ changes in 300s (5min) |
| `REDIS_SAVE_60` | `10000` | Save if 10000+ changes in 60s |
| `REDIS_RDB_COMPRESSION` | `yes` | Compress RDB files |
| `REDIS_RDB_CHECKSUM` | `yes` | Add checksum to RDB files |

### Persistence - AOF (4 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_APPENDONLY` | `no` | Enable append-only file |
| `REDIS_APPENDFSYNC` | `everysec` | Fsync policy: `always`, `everysec`, `no` |
| `REDIS_AOF_REWRITE_PERCENTAGE` | `100` | Trigger rewrite at 100% growth |
| `REDIS_AOF_REWRITE_MIN_SIZE` | `64mb` | Minimum size for rewrite |

### Performance (5 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_DATABASES` | `16` | Number of databases (0-N) |
| `REDIS_TCP_BACKLOG` | `511` | TCP listen backlog |
| `REDIS_TIMEOUT` | `0` | Client timeout in seconds (0 = disabled) |
| `REDIS_TCP_KEEPALIVE` | `300` | TCP keepalive interval in seconds |
| `REDIS_MAXCLIENTS` | `10000` | Maximum number of clients |

### Monitoring (3 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_SLOWLOG_LOG_SLOWER_THAN` | `10000` | Slow log threshold in microseconds |
| `REDIS_SLOWLOG_MAX_LEN` | `128` | Max slow log entries |
| `REDIS_LATENCY_MONITOR_THRESHOLD` | `0` | Latency monitor threshold in ms (0 = disabled) |

### Security (2 variables)

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_PROTECTED_MODE` | `yes` | Enable protected mode |
| `REDIS_RENAME_COMMANDS` | (none) | Comma-separated commands to disable |

### Flexibility (1 variable)

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_EXTRA_OPTS` | (none) | Additional redis-server options |

## Total: 27 Configurable Variables

## Usage Examples

### Basic Development

```bash
flox activate -s
redis-cli -p 16379
```

### Production with Authentication

```bash
REDIS_PASSWORD=strongpassword123 \
REDIS_MAXMEMORY=2gb \
REDIS_MAXMEMORY_POLICY=allkeys-lru \
flox activate -s
```

### High-Durability Configuration

```bash
REDIS_APPENDONLY=yes \
REDIS_APPENDFSYNC=everysec \
REDIS_SAVE_RDB=yes \
flox activate -s
```

### Cache-Only (No Persistence)

```bash
REDIS_SAVE_RDB=no \
REDIS_APPENDONLY=no \
REDIS_MAXMEMORY=1gb \
REDIS_MAXMEMORY_POLICY=allkeys-lru \
flox activate -s
```

### Network-Accessible with Security

```bash
REDIS_HOST=0.0.0.0 \
REDIS_PORT=6379 \
REDIS_PASSWORD=securepass \
REDIS_PROTECTED_MODE=yes \
REDIS_MAXCLIENTS=1000 \
flox activate -s
```

### Disable Dangerous Commands

```bash
REDIS_RENAME_COMMANDS=FLUSHDB,FLUSHALL,CONFIG \
REDIS_PASSWORD=admin123 \
flox activate -s
```

### Performance Tuning

```bash
REDIS_MAXMEMORY=4gb \
REDIS_MAXMEMORY_POLICY=allkeys-lfu \
REDIS_MAXMEMORY_SAMPLES=10 \
REDIS_TCP_BACKLOG=1024 \
REDIS_MAXCLIENTS=20000 \
flox activate -s
```

### Enable Monitoring

```bash
REDIS_SLOWLOG_LOG_SLOWER_THAN=1000 \
REDIS_SLOWLOG_MAX_LEN=1000 \
REDIS_LATENCY_MONITOR_THRESHOLD=100 \
flox activate -s
```

## Service Management

```bash
# Start service
flox activate -s

# Check status
flox services status

# View logs
flox services logs redis

# Restart with new settings
REDIS_MAXMEMORY=1gb flox services restart redis

# Stop service
flox services stop redis
```

## Connection

```bash
# Local connection
redis-cli -p 16379

# With password
redis-cli -p 16379 -a yourpassword

# Remote connection
redis-cli -h 192.168.1.100 -p 16379 -a yourpassword

# Using environment variables
redis-cli -h $REDIS_HOST -p $REDIS_PORT $([ -n "$REDIS_PASSWORD" ] && echo "-a $REDIS_PASSWORD")
```

## Monitoring and Diagnostics

```bash
# View configuration
redis-info

# Check slow queries
redis-cli SLOWLOG GET 10

# Check latency events (if latency monitor enabled)
redis-cli LATENCY DOCTOR

# Monitor commands in real-time
redis-cli MONITOR

# Get server info
redis-cli INFO

# Check memory usage
redis-cli INFO MEMORY

# Check persistence status
redis-cli INFO PERSISTENCE
```

## File Locations

- **Config**: `$REDIS_CONFIG_DIR/redis.conf`
- **Data**: `$REDIS_DIR/` (customizable via `REDIS_DIR`)
- **Logs**: `$REDIS_LOG_DIR/redis.log`
- **RDB Dump**: `$REDIS_DIR/dump.rdb`
- **AOF**: `$REDIS_DIR/appendonly.aof`

## Persistence Strategies

### Strategy 1: RDB Only (Default)
- **Use case**: Development, periodic backups
- **Config**: `REDIS_SAVE_RDB=yes`, `REDIS_APPENDONLY=no`
- **Pros**: Low overhead, compact backups
- **Cons**: May lose data between snapshots

### Strategy 2: AOF Only
- **Use case**: Better durability than RDB
- **Config**: `REDIS_SAVE_RDB=no`, `REDIS_APPENDONLY=yes`
- **Pros**: Minimal data loss
- **Cons**: Larger files, slower restarts

### Strategy 3: RDB + AOF (Recommended for Production)
- **Use case**: Production, critical data
- **Config**: `REDIS_SAVE_RDB=yes`, `REDIS_APPENDONLY=yes`
- **Pros**: Best of both worlds
- **Cons**: Higher overhead

### Strategy 4: No Persistence
- **Use case**: Pure caching, ephemeral data
- **Config**: `REDIS_SAVE_RDB=no`, `REDIS_APPENDONLY=no`
- **Pros**: Maximum performance
- **Cons**: All data lost on restart

## Memory Eviction Policies Guide

| Policy | Use Case | Description |
|--------|----------|-------------|
| `noeviction` | Database | Never evict, return errors when full |
| `allkeys-lru` | General cache | Evict least recently used keys |
| `allkeys-lfu` | Frequency-based cache | Evict least frequently used keys |
| `volatile-lru` | Cache with TTL | Evict LRU among keys with expire |
| `volatile-lfu` | Cache with TTL | Evict LFU among keys with expire |
| `volatile-ttl` | TTL-based | Evict keys with nearest expiration |
| `allkeys-random` | Random eviction | Evict random keys |
| `volatile-random` | Random with TTL | Evict random keys with expire |

## Security Best Practices

### Development
```bash
REDIS_HOST=127.0.0.1 \
REDIS_PROTECTED_MODE=yes \
flox activate -s
```

### Production
```bash
REDIS_HOST=0.0.0.0 \
REDIS_PASSWORD=<strong-password> \
REDIS_PROTECTED_MODE=yes \
REDIS_RENAME_COMMANDS=FLUSHDB,FLUSHALL,CONFIG,DEBUG \
REDIS_MAXCLIENTS=1000 \
flox activate -s
```

**Additional recommendations**:
- Use firewall rules to restrict access
- Enable TLS/SSL for remote connections (via `REDIS_EXTRA_OPTS`)
- Regularly rotate passwords
- Monitor for unusual activity via slow log
- Run with minimal OS privileges

## Performance Tuning

### High Throughput
```bash
REDIS_MAXCLIENTS=20000 \
REDIS_TCP_BACKLOG=1024 \
REDIS_TIMEOUT=0 \
REDIS_TCP_KEEPALIVE=60
```

### Memory-Constrained
```bash
REDIS_MAXMEMORY=512mb \
REDIS_MAXMEMORY_POLICY=allkeys-lru \
REDIS_DATABASES=8
```

### Low Latency
```bash
REDIS_APPENDFSYNC=no \
REDIS_SAVE_RDB=no \
REDIS_SLOWLOG_LOG_SLOWER_THAN=100
```

## Troubleshooting

### Check logs
```bash
cat $REDIS_LOG_DIR/redis.log
```

### Verify configuration
```bash
redis-cli CONFIG GET '*'
```

### Test connection
```bash
redis-cli -h $REDIS_HOST -p $REDIS_PORT PING
```

### Check memory usage
```bash
redis-cli INFO MEMORY | grep used_memory_human
```

### View active clients
```bash
redis-cli CLIENT LIST
```

## Environment Variable Injection

Change settings without editing files:

```bash
# Single session override
REDIS_PORT=6380 flox activate -s

# Permanent override in shell
export REDIS_MAXMEMORY=2gb
export REDIS_PASSWORD=mypass
flox activate -s

# CI/CD integration
env REDIS_APPENDONLY=yes REDIS_SAVE_RDB=yes flox activate -s
```

## Containerization

This environment works well in containers:

```dockerfile
# Example Dockerfile pattern
FROM nixos/nix
RUN nix-env -iA nixpkgs.flox
COPY redis-headless /app/redis-headless
WORKDIR /app/redis-headless
ENV REDIS_HOST=0.0.0.0
ENV REDIS_PORT=6379
ENV REDIS_PASSWORD=containerpass
CMD flox activate -s
```

## Multi-Instance Setup

Run multiple Redis instances:

```bash
# Instance 1
REDIS_PORT=6380 REDIS_DIR=/tmp/redis1 flox activate -s

# Instance 2 (separate terminal)
REDIS_PORT=6381 REDIS_DIR=/tmp/redis2 flox activate -s
```

## Learn More

- [Redis Documentation](https://redis.io/documentation)
- [Redis Configuration](https://redis.io/docs/management/config/)
- [Persistence](https://redis.io/docs/management/persistence/)
- [Security](https://redis.io/docs/management/security/)
- [Replication](https://redis.io/docs/management/replication/)
- [Memory Optimization](https://redis.io/docs/manual/eviction/)

## Notes

- Default port `16379` avoids conflicts with system Redis (`6379`)
- All data stored in `$FLOX_ENV_CACHE` for environment isolation
- Configuration regenerated on each activation
- All variables have sensible defaults
- Supports runtime override via environment variable injection
- Safe to restart service with new settings: `flox services restart redis`
