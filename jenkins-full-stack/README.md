# jenkins-full-stack - Production-Ready Jenkins with Nginx

A production-ready Jenkins environment with nginx as a reverse proxy, combining `nginx-headless` and `jenkins-headless` into a complete CI/CD stack.

## Features

- **Nginx Reverse Proxy** - Production-ready nginx fronting Jenkins
- **WebSocket Support** - Enabled for Jenkins agent connections
- **Gzip Compression** - Reduces bandwidth and improves performance
- **Optional Rate Limiting** - Protect Jenkins from abuse
- **Optional Security Headers** - X-Frame-Options, HSTS, CSP, etc.
- **Long Proxy Timeout** - 5-minute default for long-running builds
- **Zero Configuration** - Works out of the box with sensible defaults
- **Runtime Configurable** - All settings via environment variables
- **Composable** - Built from reusable Flox environments

## Quick Start

```bash
cd jenkins-full-stack
flox activate -s
```

This starts:
- Jenkins on port 8080 (internal)
- Nginx on port 8000 (public)
- Nginx proxies all requests to Jenkins

Access Jenkins at: **http://localhost:8000/**

Login with: **admin / changeme**

## Architecture

```
User Browser
    ↓
nginx:8000 (public)
    ↓ [reverse proxy]
Jenkins:8080 (internal)
```

**Why nginx?**
- SSL/TLS termination
- Load balancing for multiple Jenkins controllers
- Rate limiting and security features
- Static file caching
- Professional production setup

## Configuration

### Environment Variables

All configuration is runtime-overridable:

#### Nginx Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_PORT` | `8000` | Nginx public port (use 80 for production with root) |
| `NGINX_HOST` | `0.0.0.0` | Listen address |
| `NGINX_BACKEND_HOST` | `127.0.0.1` | Jenkins host (internal) |
| `NGINX_BACKEND_PORT` | `8080` | Jenkins port (internal) |
| `NGINX_WEBSOCKET_ENABLED` | `true` | WebSocket support for Jenkins agents |
| `NGINX_GZIP_ENABLED` | `true` | Gzip compression |
| `NGINX_PROXY_TIMEOUT` | `300s` | Proxy timeout (5 minutes for long builds) |

#### Optional Nginx Features

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_RATE_LIMIT_ENABLED` | `false` | Enable rate limiting |
| `NGINX_RATE_LIMIT_RATE` | `100r/s` | Requests per second (when enabled) |
| `NGINX_SECURITY_HEADERS_ENABLED` | `false` | Enable security headers |

#### Jenkins Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `JENKINS_PORT` | `8080` | Jenkins internal port |
| `JENKINS_PREFIX` | `/` | URL prefix |
| `JENKINS_PLUGINS` | `git workflow-aggregator docker-workflow github configuration-as-code` | Plugins to install |
| `JENKINS_ADMIN_USER` | `admin` | Admin username |
| `JENKINS_ADMIN_PASSWORD` | `changeme` | Admin password (**CHANGE IN PRODUCTION**) |

See [jenkins-headless README](../jenkins-headless/README.md) for full Jenkins configuration options.

## Commands

### Stack Management

```bash
# Show configuration
jenkins-stack-info

# Check health of all services
jenkins-stack-health

# Get nginx URL
jenkins-stack-url

# View recent logs from both services
jenkins-stack-logs
```

### Service Management

```bash
# Start all services
flox activate -s

# Check service status
flox services status

# View nginx logs
flox services logs nginx

# View Jenkins logs
flox services logs jenkins

# Restart a service
flox services restart nginx
flox services restart jenkins

# Stop all services
flox services stop
```

## Usage Examples

### Example 1: Basic Development Stack

```bash
cd jenkins-full-stack
flox activate -s
```

Access: http://localhost:8000/

### Example 2: Custom Port

```bash
NGINX_PORT=9000 flox activate -s
```

Access: http://localhost:9000/

### Example 3: Custom Jenkins Port

```bash
JENKINS_PORT=9191 flox activate -s
```

**Note:** `NGINX_BACKEND_PORT` automatically synchronizes with `JENKINS_PORT`, so nginx will correctly proxy to port 9191.

### Example 4: Production Port (Requires Root)

```bash
sudo NGINX_PORT=80 flox activate -s
```

Access: http://localhost/

### Example 5: With Rate Limiting

```bash
NGINX_PORT=8000 \
NGINX_RATE_LIMIT_ENABLED=true \
NGINX_RATE_LIMIT_RATE=50r/s \
flox activate -s
```

### Example 6: With Security Headers

```bash
NGINX_PORT=8000 \
NGINX_SECURITY_HEADERS_ENABLED=true \
flox activate -s
```

### Example 7: Production Configuration

```bash
NGINX_PORT=80 \
NGINX_RATE_LIMIT_ENABLED=true \
NGINX_RATE_LIMIT_RATE=100r/s \
NGINX_SECURITY_HEADERS_ENABLED=true \
NGINX_GZIP_ENABLED=true \
JENKINS_PLUGINS="git workflow-aggregator docker-workflow github blueocean configuration-as-code" \
flox activate -s
```

### Example 8: Different Jenkins Plugins

```bash
JENKINS_PLUGINS="git workflow-aggregator kubernetes docker-workflow" \
flox activate -s
```

## SSL/TLS Configuration

To add SSL/TLS support, configure nginx-headless SSL variables:

```bash
NGINX_PORT=443 \
NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/path/to/fullchain.pem \
NGINX_SSL_KEY=/path/to/privkey.pem \
NGINX_SECURITY_HEADERS_ENABLED=true \
flox activate -s
```

**Let's Encrypt Example:**

```bash
# Generate certificates with certbot first
sudo certbot certonly --standalone -d jenkins.example.com

# Then start stack
NGINX_PORT=443 \
NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/etc/letsencrypt/live/jenkins.example.com/fullchain.pem \
NGINX_SSL_KEY=/etc/letsencrypt/live/jenkins.example.com/privkey.pem \
NGINX_SECURITY_HEADERS_ENABLED=true \
NGINX_FORCE_HTTPS=true \
flox activate -s
```

Access: https://jenkins.example.com/

## Testing

### Verify Stack is Running

```bash
# Activate environment
flox activate

# Check stack health
jenkins-stack-health
```

Expected output:
```
Checking Jenkins Full Stack health...

✅ Nginx is responding at http://localhost:8000/
✅ Jenkins is accessible through nginx
✅ Jenkins API is responding

Stack is healthy!
Access Jenkins: http://localhost:8000/
```

### Manual Health Checks

```bash
# Check nginx
curl -I http://localhost:8000/

# Check Jenkins through nginx
curl -s http://localhost:8000/login | grep "<title>"

# Check Jenkins API through nginx
curl -s -u admin:changeme http://localhost:8000/api/json | jq '.mode'
```

### Verify WebSocket Support

WebSocket support is critical for Jenkins agents. Verify nginx is proxying WebSocket connections:

```bash
# Check nginx configuration
cat ~/.flox/cache/jenkins-full-stack/config/nginx.conf | grep -A 3 "Upgrade"
```

Should show:
```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

## Directory Structure

```
jenkins-full-stack/
├── .flox/
│   ├── env/
│   │   └── manifest.toml         # Environment definition
│   └── cache/
│       ├── config/               # From nginx-headless
│       │   └── nginx.conf        # Generated nginx config
│       ├── data/                 # From jenkins-headless
│       │   └── jenkins-home/     # Jenkins data directory
│       └── logs/                 # Combined logs
│           ├── nginx.log         # Nginx logs
│           ├── jenkins.log       # Jenkins logs
│           ├── access.log        # Nginx access logs
│           └── error.log         # Nginx error logs
└── README.md
```

## Composition Details

This environment is composed of two Flox environments:

1. **nginx-headless** (remote: `barstoolbluz/nginx-headless`)
   - Provides nginx service
   - Configured as reverse proxy
   - WebSocket support enabled

2. **jenkins-headless** (local: `../jenkins-headless`)
   - Provides Jenkins service
   - Runs on port 8080 (internal)
   - Configuration as Code (JCasC) enabled

**Include Configuration:**

```toml
[include]
environments = [
  { remote = "barstoolbluz/nginx-headless" },
  { dir = "../jenkins-headless" },
]
```

*Note: Once jenkins-headless is pushed to FloxHub, change to:*
```toml
  { remote = "barstoolbluz/jenkins-headless" },
```

## Service Startup Order

When you run `flox activate -s`, both services start in parallel:

1. **nginx** - Starts immediately, begins proxying requests
2. **jenkins** - Takes ~10-30 seconds to fully start

During Jenkins startup, nginx will show 502 errors. This is normal. Once Jenkins is ready, nginx automatically proxies requests successfully.

**Monitor startup:**

```bash
# Watch Jenkins logs
flox services logs jenkins --follow

# Wait for this message:
# "Jenkins is fully up and running"
```

## Troubleshooting

### Nginx Returns 502 Bad Gateway

**Cause:** Jenkins hasn't finished starting yet.

**Solution:** Wait for Jenkins to start (10-30 seconds). Monitor with:

```bash
flox services logs jenkins
```

Look for: `Jenkins is fully up and running`

### Port Already in Use

**Error:**
```
nginx: [emerg] bind() to 0.0.0.0:8000 failed (98: Address already in use)
```

**Solution:** Change the nginx port:

```bash
NGINX_PORT=9000 flox activate -s
```

### Cannot Access Jenkins

**Check:**

```bash
# 1. Check service status
flox services status

# 2. Check nginx is running
curl -I http://localhost:8000/

# 3. Check Jenkins is running
curl -I http://localhost:8080/

# 4. Check nginx logs
flox services logs nginx

# 5. Check Jenkins logs
flox services logs jenkins
```

### WebSocket Connections Failing

**Verify WebSocket support is enabled:**

```bash
# In activated environment
echo $NGINX_WEBSOCKET_ENABLED  # Should be "true"

# Check nginx config
grep -i upgrade ~/.flox/cache/jenkins-full-stack/config/nginx.conf
```

**If disabled, enable it:**

```bash
NGINX_WEBSOCKET_ENABLED=true flox activate -s
```

### Jenkins Agent Connection Issues

**Cause:** Nginx may be blocking WebSocket upgrade.

**Solution:** Ensure `NGINX_WEBSOCKET_ENABLED=true` (default) and restart:

```bash
flox services restart nginx
```

### Rate Limiting Too Aggressive

**Symptoms:** 503 errors under load

**Solution:** Increase rate limit:

```bash
NGINX_RATE_LIMIT_RATE=200r/s \
NGINX_RATE_LIMIT_BURST=400 \
flox activate -s
```

## Production Deployment Checklist

Before deploying to production:

- [ ] **Change admin password**
  - Create `~/.config/jenkins/credentials` with `JENKINS_ADMIN_PASSWORD`
  - Or set via environment variable

- [ ] **Configure SSL/TLS**
  - Obtain valid certificates (Let's Encrypt recommended)
  - Set `NGINX_SSL_ENABLED=true`
  - Provide cert paths

- [ ] **Enable security features**
  - `NGINX_SECURITY_HEADERS_ENABLED=true`
  - `NGINX_RATE_LIMIT_ENABLED=true`
  - `NGINX_FORCE_HTTPS=true` (if using SSL)

- [ ] **Configure backup**
  - Backup `$FLOX_ENV_CACHE/data/jenkins-home/`
  - Store in secure location

- [ ] **Configure plugins**
  - Review and customize `JENKINS_PLUGINS` for your needs
  - Test all plugins work together

- [ ] **Review JCasC configuration**
  - Edit `$FLOX_ENV_CACHE/config/jenkins.yaml`
  - Add organization-specific settings

- [ ] **Configure firewall**
  - Allow inbound traffic on nginx port
  - Block direct access to Jenkins port (8080)

- [ ] **Test disaster recovery**
  - Document restore procedure
  - Test backup restoration

## Performance Tuning

### For High-Traffic Deployments

```bash
# Increase nginx worker connections
NGINX_WORKER_CONNECTIONS=4096 \
NGINX_GZIP_ENABLED=true \
NGINX_RATE_LIMIT_RATE=1000r/s \
NGINX_RATE_LIMIT_BURST=2000 \
flox activate -s
```

### For Long-Running Builds

```bash
# Increase proxy timeout for very long builds
NGINX_PROXY_TIMEOUT=600s \
flox activate -s
```

### For Large Teams

```bash
# Increase rate limit and enable caching
NGINX_RATE_LIMIT_RATE=500r/s \
NGINX_RATE_LIMIT_BURST=1000 \
NGINX_GZIP_ENABLED=true \
flox activate -s
```

## Advanced Configuration

### Custom Jenkins Configuration

Edit the JCasC configuration:

```bash
# Activate environment
flox activate

# Edit JCasC config
nano $FLOX_ENV_CACHE/config/jenkins.yaml

# Restart Jenkins to apply
flox services restart jenkins
```

### Custom Nginx Configuration

Nginx configuration is generated from templates. To customize:

```bash
# View generated config
cat ~/.flox/cache/jenkins-full-stack/config/nginx.conf

# For advanced changes, edit nginx-headless templates
# See: nginx-headless README.md
```

### Adding More Services

You can extend this stack by including additional environments:

```toml
[include]
environments = [
  { remote = "barstoolbluz/nginx-headless" },
  { dir = "../jenkins-headless" },
  { remote = "barstoolbluz/postgres-headless" },  # Add database
  { remote = "barstoolbluz/redis-headless" },     # Add cache
]
```

## Security Considerations

### Default Credentials

**⚠️ WARNING:** Default admin password is `changeme`

**Change it before production deployment:**

```bash
# Option 1: Environment variable
export JENKINS_ADMIN_PASSWORD="your-secure-password"
flox activate -s

# Option 2: Persistent storage
mkdir -p ~/.config/jenkins
echo 'export JENKINS_ADMIN_PASSWORD="your-secure-password"' > ~/.config/jenkins/credentials
chmod 600 ~/.config/jenkins/credentials
flox activate -s
```

### Network Security

1. **Firewall Configuration:**
   - Allow: nginx port (80/443/8000)
   - Block: Jenkins port (8080) from external access

2. **Reverse Proxy Security:**
   - Nginx should be the only public entry point
   - Jenkins should only be accessible via nginx proxy

3. **Rate Limiting:**
   - Enable rate limiting to prevent brute force attacks
   - Adjust based on your team size and usage patterns

### SSL/TLS Best Practices

- Use Let's Encrypt for free, valid certificates
- Enable HSTS with `NGINX_SECURITY_HEADERS_ENABLED=true`
- Force HTTPS with `NGINX_FORCE_HTTPS=true`
- Keep certificates renewed and up to date

## Kubernetes Integration

This stack can be used as a Jenkins controller for Kubernetes-based builds:

1. **Install Kubernetes plugin:**
   ```bash
   JENKINS_PLUGINS="git workflow-aggregator kubernetes docker-workflow github configuration-as-code" \
   flox activate -s
   ```

2. **Configure Kubernetes in JCasC:**
   Edit `$FLOX_ENV_CACHE/config/jenkins.yaml` to add Kubernetes cloud configuration

3. **Dynamic Agent Provisioning:**
   Jenkins will automatically create pods in your Kubernetes cluster for builds

See [jenkins-headless README](../jenkins-headless/README.md) for detailed Kubernetes configuration.

## Monitoring and Logging

### Access Logs

```bash
# Real-time nginx access log
tail -f ~/.flox/cache/jenkins-full-stack/logs/access.log

# Real-time Jenkins log
flox services logs jenkins --follow
```

### Log Locations

- **Nginx access log:** `~/.flox/cache/jenkins-full-stack/logs/access.log`
- **Nginx error log:** `~/.flox/cache/jenkins-full-stack/logs/error.log`
- **Jenkins log:** `~/.flox/cache/jenkins-full-stack/logs/jenkins.log`
- **Service logs:** `~/.flox/log/services.*.log`

## Comparison to Other Setups

| Setup | Pros | Cons |
|-------|------|------|
| **jenkins-headless** | Simple, direct access | No SSL termination, no load balancing |
| **jenkins-full-stack** | Production-ready, SSL support, rate limiting | More complex, more resources |
| **Traditional Docker** | Well-documented | Less portable, requires Docker |
| **Traditional VM** | Complete isolation | Heavy resource usage |

**When to use jenkins-full-stack:**
- ✅ Production deployments
- ✅ Need SSL/TLS support
- ✅ Need rate limiting
- ✅ Need professional nginx features
- ✅ Multiple Jenkins controllers (load balancing)

**When to use jenkins-headless:**
- ✅ Local development
- ✅ Simple testing
- ✅ Learning Jenkins
- ✅ Minimal resource usage

## Related Environments

- **jenkins-headless** - Standalone Jenkins without nginx
- **nginx-headless** - Nginx reverse proxy (composable)
- **postgres-headless** - PostgreSQL database
- **redis-headless** - Redis cache

## Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Jenkins Configuration as Code](https://github.com/jenkinsci/configuration-as-code-plugin)
- [Let's Encrypt](https://letsencrypt.org/)

## Support

### Check Logs

```bash
flox services logs nginx
flox services logs jenkins
```

### Check Service Status

```bash
flox services status
```

### Test Connectivity

```bash
jenkins-stack-health
```

### Debug nginx Configuration

```bash
# View generated config
cat ~/.flox/cache/jenkins-full-stack/config/nginx.conf

# Test config
nginx -t -c ~/.flox/cache/jenkins-full-stack/config/nginx.conf
```

## Contributing

This environment is part of the floxenvs repository. See the main repository for contribution guidelines.

## License

This Flox environment configuration is provided as-is. Jenkins and nginx are licensed under their respective licenses.
