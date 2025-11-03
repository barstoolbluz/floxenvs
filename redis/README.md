# Redis Interactive Environment

A fully-configured Redis environment for Flox with an interactive setup wizard powered by `gum`.

## Features

- **Interactive Configuration**: First-run wizard with customizable settings
- **Persistent Configuration**: Settings saved and reused across sessions
- **Service Management**: Built-in service controls via Flox
- **Multiple Persistence Options**: RDB snapshots and AOF logging
- **Memory Management**: Configurable memory limits and eviction policies
- **Multiple Shell Support**: Works with bash, zsh, and fish

## Quick Start

```bash
# Initialize and activate (triggers configuration wizard on first run)
cd redis
flox activate

# Start Redis as a service
flox activate -s

# Connect to Redis
redis-cli -p 16379

# Reconfigure Redis
redisconfigure
```

## Configuration Options

The interactive wizard lets you customize:

### Connection Settings
- **Host Address**: Bind address (default: `127.0.0.1`)
- **Port**: Redis port (default: `16379`)
- **Password**: Optional authentication (default: none)
- **Data Directory**: Storage location (default: `$FLOX_ENV_CACHE/redis`)

### Memory Management
- **Max Memory**: Memory limit (default: `256mb`)
- **Eviction Policy**: Strategy when max memory reached
  - `noeviction`: Return errors when memory limit reached
  - `allkeys-lru`: Evict least recently used keys
  - `volatile-lru`: Evict LRU keys with expire set
  - `allkeys-random`: Evict random keys
  - `volatile-random`: Evict random keys with expire set
  - `volatile-ttl`: Evict keys with nearest expire time
  - `allkeys-lfu`: Evict least frequently used keys
  - `volatile-lfu`: Evict LFU keys with expire set

### Persistence Settings

#### RDB Snapshots (Point-in-Time Backups)
- **Enable/Disable**: Toggle RDB persistence
- **Save Intervals**: When to create snapshots (default: `900 1 300 10 60 10000`)
  - Format: `seconds changes` pairs
  - Example: `900 1` = save after 900s if 1+ keys changed

#### AOF (Append Only File)
- **Enable/Disable**: Toggle AOF persistence
- **Fsync Policy**: Durability vs performance trade-off
  - `everysec`: Fsync every second (good balance)
  - `always`: Fsync after every write (safest, slowest)
  - `no`: Let OS decide when to fsync (fastest, least safe)

### Other Settings
- **Databases**: Number of databases (default: `16`)

## Service Management

```bash
# Start Redis service
flox activate -s
# or after activation:
redisstart

# Stop Redis service
redisstop

# Restart Redis service
redisrestart

# Reconfigure (wizard + restart)
redisconfigure
```

## Connecting to Redis

```bash
# Basic connection
redis-cli -h 127.0.0.1 -p 16379

# With password (if configured)
redis-cli -h 127.0.0.1 -p 16379 -a yourpassword

# Using environment variables
redis-cli  # Uses REDIS_HOST and REDIS_PORT from config
```

## Configuration File Locations

- **Environment Config**: `$FLOX_ENV_CACHE/redis.config`
- **Redis Config**: `$REDIS_DIR/redis.conf`
- **Data Directory**: `$REDIS_DIR/data/`
- **Log File**: `$REDIS_DIR/redis.log`

## Reconfiguring

To change your Redis configuration after the initial setup:

```bash
redisconfigure
```

This will:
1. Stop the Redis service
2. Run the configuration wizard
3. Regenerate `redis.conf`
4. Restart the service with new settings

## Advanced Usage

### Manual Configuration Override

You can manually edit the configuration file:

```bash
$EDITOR $FLOX_ENV_CACHE/redis.config
```

Then restart Redis:

```bash
redisrestart
```

### Using Different Configurations

The configuration is stored in `$FLOX_ENV_CACHE/redis.config`. To reset:

```bash
rm $FLOX_ENV_CACHE/redis.config
flox activate  # Triggers wizard again
```

## Persistence Strategies

### Development (Default)
- RDB: Enabled with standard intervals
- AOF: Disabled
- Good for: Local development, testing

### Production (High Durability)
```
RDB: Enabled
AOF: Enabled with 'everysec' or 'always'
Good for: Production data that must survive crashes
```

### Cache Only (No Persistence)
```
RDB: Disabled
AOF: Disabled
Good for: Pure caching, ephemeral data
```

### Maximum Performance
```
RDB: Disabled or infrequent intervals
AOF: Disabled or 'no' fsync
⚠️ Risk: Potential data loss
```

## Memory Eviction Policies

Choose based on your use case:

- **Cache (all keys)**: Use `allkeys-lru` or `allkeys-lfu`
- **Cache (with TTL)**: Use `volatile-lru` or `volatile-lfu`
- **Never evict**: Use `noeviction` (will return errors when full)
- **TTL-based**: Use `volatile-ttl` (evicts soonest-expiring keys)

## Troubleshooting

### Redis Won't Start

Check the log file:
```bash
cat $REDIS_DIR/redis.log
```

### Port Already in Use

Change the port during configuration or edit:
```bash
$EDITOR $FLOX_ENV_CACHE/redis.config
```

### Permission Issues

The data directory should be `chmod 700`. If issues persist:
```bash
chmod 700 $REDIS_DIR
chmod 700 $REDIS_DIR/data
```

### Connection Refused

Ensure:
1. Redis service is running: `flox services status`
2. Using correct host/port
3. Password is correct (if set)

## Environment Variables

After configuration, these variables are available in your shell:

- `REDIS_HOST`: Bind address
- `REDIS_PORT`: Port number
- `REDIS_PASSWORD`: Password (if set)
- `REDIS_DIR`: Data directory
- `REDIS_CONF_FILE`: Config file path
- `REDIS_LOG_FILE`: Log file path
- `REDIS_MAXMEMORY`: Memory limit
- `REDIS_MAXMEMORY_POLICY`: Eviction policy
- `REDIS_SAVE_RDB`: RDB enabled/disabled
- `REDIS_APPENDONLY`: AOF enabled/disabled
- `REDIS_DATABASES`: Number of databases

## Shell Functions

These functions are available in bash, zsh, and fish:

- `redisstart`: Start Redis service
- `redisstop`: Stop Redis service
- `redisrestart`: Restart Redis service
- `redisconfigure`: Reconfigure Redis (wizard + restart)

## Notes

- Default port `16379` avoids conflicts with system Redis (6379)
- All data stored in `$FLOX_ENV_CACHE` for isolation
- Configuration persists across environment activations
- Safe to run `flox activate` multiple times (idempotent)

## Security Considerations

⚠️ **For production use**:
- Set a strong password
- Don't bind to `0.0.0.0` unless necessary
- Use firewall rules to restrict access
- Enable protected mode (default)
- Consider renaming dangerous commands (FLUSHDB, etc.)
- Use TLS for remote connections

## Learn More

- [Redis Documentation](https://redis.io/documentation)
- [Redis Configuration](https://redis.io/docs/management/config/)
- [Persistence Strategies](https://redis.io/docs/management/persistence/)
- [Memory Optimization](https://redis.io/docs/manual/eviction/)
