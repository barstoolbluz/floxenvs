# nginx-headless - Composable Nginx Environment

A headless, runtime-configurable nginx environment designed for automation, composition, and production deployments.

## Features

- **3 Operation Modes**: Reverse proxy, static file serving, load balancing
- **SSL/TLS Support**: Optional HTTPS with certificate management
- **Rate Limiting**: API protection and DDoS prevention
- **Gzip Compression**: Response compression for bandwidth savings
- **Security Headers**: X-Frame-Options, CSP, HSTS, and more
- **Caching**: Browser/proxy caching with Cache-Control headers
- **WebSocket Proxying**: Full WebSocket protocol support
- **URL Rewriting**: HTTPS redirects and WWW enforcement
- **Runtime Configuration**: All settings via environment variables
- **Zero Interaction**: Perfect for CI/CD, containers, and composed environments
- **Template-Based**: Modify templates for advanced use cases

## Quick Start

### Reverse Proxy (Default)

```bash
cd nginx-headless
flox activate -s
```

This starts nginx as a reverse proxy to `127.0.0.1:8080` on port `80`.

### Custom Backend

```bash
NGINX_BACKEND_HOST=api.internal \
NGINX_BACKEND_PORT=3000 \
NGINX_PORT=8080 \
flox activate -s
```

### Static File Server

```bash
NGINX_MODE=static \
NGINX_ROOT=/var/www/mysite \
NGINX_PORT=8080 \
flox activate -s
```

### Load Balancer

```bash
NGINX_MODE=load_balancer \
NGINX_UPSTREAM_SERVERS="app1:8080,app2:8080,app3:8080" \
NGINX_LB_METHOD=least_conn \
flox activate -s
```

## Configuration

### Mode Selection

| Variable | Default | Options |
|----------|---------|---------|
| `NGINX_MODE` | `proxy` | `proxy`, `static`, `load_balancer` |

### Common Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_PORT` | `80` | Listen port |
| `NGINX_HOST` | `0.0.0.0` | Listen address |
| `NGINX_WORKER_PROCESSES` | `auto` | Number of worker processes |
| `NGINX_WORKER_CONNECTIONS` | `1024` | Connections per worker |

### Reverse Proxy Mode

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_BACKEND_HOST` | `127.0.0.1` | Upstream server host |
| `NGINX_BACKEND_PORT` | `8080` | Upstream server port |
| `NGINX_PROXY_TIMEOUT` | `60s` | Proxy timeout |

### Static File Mode

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_ROOT` | `$FLOX_ENV_CACHE/www` | Document root path |
| `NGINX_INDEX` | `index.html index.htm` | Index file(s) |

### Load Balancer Mode

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_UPSTREAM_SERVERS` | *(required)* | Comma-separated server list |
| `NGINX_LB_METHOD` | `round_robin` | `round_robin`, `least_conn`, `ip_hash` |

### SSL/TLS Feature

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_SSL_ENABLED` | `false` | Enable HTTPS |
| `NGINX_SSL_CERT` | | Path to SSL certificate |
| `NGINX_SSL_KEY` | | Path to SSL private key |
| `NGINX_SSL_PROTOCOLS` | `TLSv1.2 TLSv1.3` | Allowed TLS protocols |

### Rate Limiting Feature

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_RATE_LIMIT_ENABLED` | `false` | Enable rate limiting |
| `NGINX_RATE_LIMIT_RATE` | `10r/s` | Requests per second |
| `NGINX_RATE_LIMIT_BURST` | `20` | Burst capacity |

### Gzip Compression Feature

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_GZIP_ENABLED` | `false` | Enable gzip compression |
| `NGINX_GZIP_LEVEL` | `6` | Compression level (1-9) |
| `NGINX_GZIP_MIN_LENGTH` | `1000` | Minimum response size to compress |
| `NGINX_GZIP_TYPES` | `text/plain text/css application/json ...` | MIME types to compress |

### Security Headers Feature

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_SECURITY_HEADERS_ENABLED` | `false` | Enable security headers |

**Headers added when enabled:**
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Referrer-Policy: no-referrer-when-downgrade`
- `Strict-Transport-Security` (only when SSL is enabled)

### Caching Feature

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_CACHE_ENABLED` | `false` | Enable browser caching (static mode only) |
| `NGINX_CACHE_HTML_EXPIRE` | `1h` | Cache expiration for HTML files |
| `NGINX_CACHE_STATIC_EXPIRE` | `7d` | Cache expiration for static assets (css, js, images) |

### WebSocket Feature

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_WEBSOCKET_ENABLED` | `false` | Enable WebSocket proxying (proxy/load_balancer modes) |

### URL Rewriting Feature

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_FORCE_HTTPS` | `false` | Force HTTPS redirect (301) |
| `NGINX_FORCE_WWW` | `none` | WWW enforcement: `add_www`, `remove_www`, or `none` |

## Usage Examples

### Example 1: Simple Reverse Proxy

Proxy requests to a local application:

```bash
NGINX_BACKEND_HOST=localhost \
NGINX_BACKEND_PORT=3000 \
flox activate -s
```

### Example 2: Reverse Proxy with SSL

```bash
NGINX_BACKEND_HOST=api.internal \
NGINX_BACKEND_PORT=8080 \
NGINX_PORT=443 \
NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/path/to/fullchain.pem \
NGINX_SSL_KEY=/path/to/privkey.pem \
flox activate -s
```

### Example 3: Static Site with Custom Port

```bash
NGINX_MODE=static \
NGINX_ROOT=/var/www/mysite \
NGINX_PORT=8080 \
flox activate -s
```

### Example 4: Load Balancer with Rate Limiting

```bash
NGINX_MODE=load_balancer \
NGINX_UPSTREAM_SERVERS="app1:8080,app2:8080,app3:8080" \
NGINX_LB_METHOD=ip_hash \
NGINX_RATE_LIMIT_ENABLED=true \
NGINX_RATE_LIMIT_RATE=100r/s \
NGINX_RATE_LIMIT_BURST=200 \
flox activate -s
```

### Example 5: API Gateway (Proxy + Rate Limiting + SSL)

```bash
NGINX_MODE=proxy \
NGINX_BACKEND_HOST=api.internal \
NGINX_BACKEND_PORT=8001 \
NGINX_PORT=443 \
NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/certs/cert.pem \
NGINX_SSL_KEY=/certs/key.pem \
NGINX_RATE_LIMIT_ENABLED=true \
NGINX_RATE_LIMIT_RATE=50r/s \
flox activate -s
```

### Example 6: Static Site with Caching and Gzip

```bash
NGINX_MODE=static \
NGINX_ROOT=/var/www/mysite \
NGINX_CACHE_ENABLED=true \
NGINX_CACHE_STATIC_EXPIRE=30d \
NGINX_GZIP_ENABLED=true \
NGINX_GZIP_LEVEL=9 \
flox activate -s
```

### Example 7: Secure Proxy with All Security Features

```bash
NGINX_BACKEND_HOST=app.internal \
NGINX_PORT=443 \
NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/certs/cert.pem \
NGINX_SSL_KEY=/certs/key.pem \
NGINX_SECURITY_HEADERS_ENABLED=true \
NGINX_GZIP_ENABLED=true \
NGINX_RATE_LIMIT_ENABLED=true \
flox activate -s
```

### Example 8: High-Performance Load Balancer

```bash
NGINX_MODE=load_balancer \
NGINX_UPSTREAM_SERVERS="app1:8080,app2:8080,app3:8080,app4:8080" \
NGINX_LB_METHOD=least_conn \
NGINX_GZIP_ENABLED=true \
NGINX_RATE_LIMIT_ENABLED=true \
NGINX_RATE_LIMIT_RATE=1000r/s \
NGINX_RATE_LIMIT_BURST=2000 \
flox activate -s
```

### Example 9: WebSocket Proxy

```bash
NGINX_BACKEND_HOST=ws.internal \
NGINX_BACKEND_PORT=3000 \
NGINX_WEBSOCKET_ENABLED=true \
flox activate -s
```

### Example 10: Force HTTPS and WWW

```bash
NGINX_PORT=443 \
NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/certs/cert.pem \
NGINX_SSL_KEY=/certs/key.pem \
NGINX_FORCE_HTTPS=true \
NGINX_FORCE_WWW=add_www \
flox activate -s
```

### Example 11: Complete Production Setup

```bash
NGINX_MODE=proxy \
NGINX_BACKEND_HOST=app.internal \
NGINX_PORT=443 \
NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/certs/fullchain.pem \
NGINX_SSL_KEY=/certs/privkey.pem \
NGINX_SECURITY_HEADERS_ENABLED=true \
NGINX_GZIP_ENABLED=true \
NGINX_RATE_LIMIT_ENABLED=true \
NGINX_WEBSOCKET_ENABLED=true \
NGINX_FORCE_HTTPS=true \
NGINX_FORCE_WWW=remove_www \
flox activate -s
```

## Mode Details

### Reverse Proxy Mode

Routes incoming requests to a backend server. Includes:
- Proxy headers (Host, X-Real-IP, X-Forwarded-For, X-Forwarded-Proto)
- Configurable timeouts
- Transparent proxying

**Use Cases:**
- API gateway
- Microservices routing
- SSL termination for backend services

### Static File Mode

Serves static files from a directory. Includes:
- MIME type detection
- Efficient sendfile
- Directory index support
- 404 error handling

**Use Cases:**
- Single-page applications
- Static websites
- Documentation hosting

### Load Balancer Mode

Distributes traffic across multiple backend servers. Includes:
- Three load balancing algorithms
- Dynamic upstream generation
- Health checking (via nginx defaults)

**Load Balancing Methods:**
- `round_robin`: Distribute evenly across servers
- `least_conn`: Route to server with fewest connections
- `ip_hash`: Sticky sessions based on client IP

**Use Cases:**
- Scaling web applications
- High-availability setups
- Traffic distribution

## Features Details

### SSL/TLS Support

Enables HTTPS with custom certificates. Automatically:
- Configures TLS 1.2 and 1.3
- Sets secure cipher suites
- Adds SSL directives to all modes

**Certificate Requirements:**
- `NGINX_SSL_CERT`: Full certificate chain (PEM format)
- `NGINX_SSL_KEY`: Private key (PEM format)

**Generating Self-Signed Cert (Testing Only):**
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/nginx-selfsigned.key \
  -out /tmp/nginx-selfsigned.crt \
  -subj "/CN=localhost"

NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/tmp/nginx-selfsigned.crt \
NGINX_SSL_KEY=/tmp/nginx-selfsigned.key \
flox activate -s
```

### Rate Limiting

Protects against abuse and DDoS attacks using nginx's leaky bucket algorithm:
- Limits requests per client IP address
- Configurable rate and burst capacity
- `nodelay` mode (reject excess immediately)

**How It Works:**
- `NGINX_RATE_LIMIT_RATE`: Sustained rate (e.g., `10r/s` = 10 requests per second)
- `NGINX_RATE_LIMIT_BURST`: Temporary burst capacity above sustained rate

**Example:** Rate `10r/s` with burst `20`:
- Steady state: Accept 10 requests per second
- Burst: Accept up to 20 requests instantly, then enforce rate limit

### Gzip Compression

Compresses responses to reduce bandwidth usage and improve load times:
- Automatically compresses configured MIME types
- Adjustable compression level (1-9, higher = better compression but more CPU)
- Minimum size threshold prevents compressing tiny responses
- Adds `Vary: Accept-Encoding` header for proper caching

**How It Works:**
- `NGINX_GZIP_LEVEL`: Compression level (6 is a good balance)
- `NGINX_GZIP_MIN_LENGTH`: Skip compression for responses smaller than this (default: 1000 bytes)
- `NGINX_GZIP_TYPES`: Only compress specified MIME types

**Performance Tips:**
- Use level 6 for best performance/compression balance
- Higher levels (7-9) use significantly more CPU for marginal gains
- Don't compress already-compressed formats (images, videos)

### Security Headers

Adds common security headers to protect against web vulnerabilities:
- **X-Frame-Options**: Prevents clickjacking attacks
- **X-Content-Type-Options**: Prevents MIME type sniffing
- **X-XSS-Protection**: Enables browser XSS protection
- **Referrer-Policy**: Controls referrer information
- **Strict-Transport-Security (HSTS)**: Forces HTTPS (only added when SSL is enabled)

**HSTS Behavior:**
- Automatically added when both `NGINX_SECURITY_HEADERS_ENABLED=true` and `NGINX_SSL_ENABLED=true`
- Sets max-age to 1 year (31536000 seconds)
- Includes subdomains

**Security Best Practices:**
- Always enable security headers for production deployments
- Combine with SSL/TLS for maximum protection
- Test HSTS carefully - once enabled, browsers cache it

### Caching

Configures browser/proxy caching to reduce server load and improve performance:
- Works in **static mode only**
- Separate cache policies for HTML and static assets
- Adds appropriate `Cache-Control` and `Expires` headers

**Cache Policies:**
- **HTML files**: Shorter cache (default: 1 hour) - allows content updates
- **Static assets** (CSS, JS, images): Longer cache (default: 7 days) - marked as immutable
- Assets matched: `jpg, jpeg, png, gif, ico, css, js, svg, woff, woff2, ttf, eot`

**How It Works:**
- HTML gets `Cache-Control: public, max-age=3600` and `Expires` header
- Static assets get `Cache-Control: public, immutable` and longer expiration
- Browsers won't re-request cached files until expiration

**Best Practices:**
- Use cache busting (e.g., `app.js?v=123`) for versioned assets
- Longer cache for static assets = faster repeat visits
- Shorter cache for HTML = faster content updates

### WebSocket Proxying

Enables full WebSocket protocol support for real-time applications:
- Works in **proxy and load_balancer modes only**
- Automatically upgrades HTTP connections to WebSocket
- Adds required headers: `Upgrade`, `Connection`
- Sets `proxy_http_version` to 1.1

**How It Works:**
- Detects WebSocket upgrade requests via `$http_upgrade` variable
- Preserves WebSocket connection through proxy
- Supports both `ws://` and `wss://` (with SSL enabled)

**Use Cases:**
- Real-time chat applications
- Live dashboards and monitoring
- WebSocket APIs
- Gaming servers
- Collaborative editing tools

**Example Configuration:**
```bash
# WebSocket server on ws://backend:3000
NGINX_BACKEND_HOST=backend
NGINX_BACKEND_PORT=3000
NGINX_WEBSOCKET_ENABLED=true
flox activate -s
```

### URL Rewriting

Provides common URL rewriting and redirect patterns:
- Force HTTPS redirects (HTTP → HTTPS)
- WWW enforcement (add or remove www subdomain)
- 301 permanent redirects for SEO
- Works across all modes

**Force HTTPS:**
- Redirects all HTTP traffic to HTTPS
- Returns 301 (permanent redirect)
- Preserves full request URI
- **Requires SSL to be configured** on the HTTPS port

**WWW Enforcement:**
- `add_www`: Redirects `example.com` → `www.example.com`
- `remove_www`: Redirects `www.example.com` → `example.com`
- `none`: No WWW redirect (default)

**How It Works:**
- Uses nginx `if` directives with `$scheme` and `$host` variables
- 301 redirects preserve query strings and paths
- Executes before location block processing

**Use Cases:**
- SEO: Consolidate domain authority to one canonical URL
- Security: Force HTTPS for all traffic
- Consistency: Ensure all traffic uses same domain format

**Example:**
```bash
# Force HTTPS and remove www
NGINX_PORT=443
NGINX_SSL_ENABLED=true
NGINX_SSL_CERT=/certs/cert.pem
NGINX_SSL_KEY=/certs/key.pem
NGINX_FORCE_HTTPS=true
NGINX_FORCE_WWW=remove_www
flox activate -s
```

**Important Notes:**
- HTTPS redirect requires SSL configuration on port 443
- Test WWW redirects carefully - affects SEO
- Both redirects can be enabled simultaneously

## Environment Composition

### Including in Other Environments

```toml
# myapp/.flox/env/manifest.toml
[include]
environments = [
  { remote = "yourorg/nginx-headless" },
]

[hook]
on-activate = '''
export NGINX_MODE="proxy"
export NGINX_BACKEND_PORT="3000"
'''
```

### Composed Stack Example

```toml
# fullstack/.flox/env/manifest.toml
[include]
environments = [
  { remote = "yourorg/nginx-headless" },
  { remote = "yourorg/postgres-headless" },
  { remote = "yourorg/redis-headless" },
]

[hook]
on-activate = '''
export NGINX_MODE="proxy"
export NGINX_BACKEND_HOST="localhost"
export NGINX_BACKEND_PORT="3000"
'''
```

Start entire stack: `flox activate -s`

## Service Management

```bash
# Start service
flox activate -s

# Check status
flox services status

# View logs
flox services logs nginx

# Restart with new configuration
flox services restart nginx

# Stop services
flox services stop
```

## Advanced Configuration

### Custom Templates

Templates are stored in `$FLOX_ENV_CACHE/config/`:
- `nginx-proxy.template` - Reverse proxy configuration
- `nginx-static.template` - Static file serving configuration
- `nginx-loadbalancer.template` - Load balancer configuration

Edit templates directly for advanced use cases:
- Add custom headers
- Configure caching
- Add location blocks
- Modify proxy behavior

After editing templates, restart the service:
```bash
flox services restart nginx
```

### Generated Configuration

The final nginx configuration is at:
```
$FLOX_ENV_CACHE/config/nginx.conf
```

View generated config:
```bash
cat .flox/cache/config/nginx.conf
```

### Logs

Logs are stored in `$FLOX_ENV_CACHE/logs/`:
- `nginx.log` - Combined stdout/stderr
- `access.log` - HTTP access logs
- `error.log` - nginx error logs

View access logs:
```bash
tail -f .flox/cache/logs/access.log
```

## Troubleshooting

### Service Won't Start

Check logs for errors:
```bash
flox services logs nginx
```

Common issues:
- **Port already in use**: Change `NGINX_PORT`
- **Permission denied**: Ports < 1024 require root (use ports ≥ 1024)
- **SSL cert not found**: Verify `NGINX_SSL_CERT` and `NGINX_SSL_KEY` paths

### Configuration Validation Failed

View the generated configuration:
```bash
cat .flox/cache/config/nginx.conf
```

Test configuration manually:
```bash
nginx -t -c .flox/cache/config/nginx.conf
```

### Load Balancer Mode Errors

Ensure `NGINX_UPSTREAM_SERVERS` is set:
```bash
NGINX_UPSTREAM_SERVERS="server1:8080,server2:8080"
```

Verify servers are reachable from nginx host.

### Rate Limiting Too Aggressive

Increase rate or burst:
```bash
NGINX_RATE_LIMIT_RATE=100r/s \
NGINX_RATE_LIMIT_BURST=200 \
flox activate -s
```

## Platform Notes

- **Linux/macOS**: Full support
- **Ports**: Use ports ≥ 1024 for non-root operation
- **Permissions**: SSL certificate files must be readable by the user running nginx

## Security Considerations

### Production Deployment

1. **Use SSL/TLS** for any external-facing deployment
2. **Enable rate limiting** to prevent abuse
3. **Restrict network access** via firewall rules
4. **Use separate user** for nginx process (configure via templates)
5. **Keep certificates secure** (permissions 600, owned by nginx user)

### SSL Best Practices

- Use Let's Encrypt for free, valid certificates
- Renew certificates before expiration
- Use strong TLS protocols (default: TLSv1.2, TLSv1.3)
- Review cipher suites for security requirements

## Examples by Use Case

### Development: Local Proxy

```bash
NGINX_BACKEND_PORT=3000 flox activate -s
```

### Staging: Proxy with Rate Limiting

```bash
NGINX_BACKEND_HOST=staging.internal \
NGINX_RATE_LIMIT_ENABLED=true \
flox activate -s
```

### Production: Full Security Stack

```bash
NGINX_PORT=443 \
NGINX_SSL_ENABLED=true \
NGINX_SSL_CERT=/etc/letsencrypt/live/example.com/fullchain.pem \
NGINX_SSL_KEY=/etc/letsencrypt/live/example.com/privkey.pem \
NGINX_RATE_LIMIT_ENABLED=true \
NGINX_RATE_LIMIT_RATE=100r/s \
NGINX_BACKEND_HOST=app.internal \
NGINX_BACKEND_PORT=8080 \
flox activate -s
```

## Related Environments

- **ollama-headless** - AI/ML inference server (works well with nginx proxy)
- **postgres-headless** - PostgreSQL database
- **redis-headless** - Redis cache/session store

## Resources

- [nginx Documentation](https://nginx.org/en/docs/)
- [nginx Rate Limiting Guide](https://www.nginx.com/blog/rate-limiting-nginx/)
- [Let's Encrypt](https://letsencrypt.org/) - Free SSL certificates

## Support

For issues with this Flox environment:
- Check logs: `flox services logs nginx`
- Validate config: `nginx -t -c .flox/cache/config/nginx.conf`
- Review generated config: `.flox/cache/config/nginx.conf`

For nginx-specific issues:
- [nginx Documentation](https://nginx.org/en/docs/)
- [nginx Community](https://forum.nginx.org/)
