# 🌐 A Flox Environment for nginx Reverse Proxy

An interactive, wizard-driven nginx reverse proxy environment that makes it easy to route traffic to your local development services. No complex configuration files—just follow the prompts.

## ✨ What You Get

- Interactive wizard to configure port-based and path-based proxying
- WebSocket support for real-time applications
- IP-based access control for security
- Zero nginx configuration knowledge required
- Persistent configuration across activations
- Setup that takes <1 minute with clear explanations

## 🧰 Tools Included

- `nginx` - High-performance reverse proxy and web server
- `curl` - For testing endpoints
- `gum` - Powers the interactive configuration wizard
- `gnugrep` - Text processing utilities

## 🚀 Getting Started

### Prerequisites

- [Flox](https://flox.dev) installed
- One or more local services you want to proxy to
- That's it!

### Quick Start

1. Navigate to the nginx environment
```bash
cd nginx
```

2. Activate and let the wizard guide you
```bash
flox activate -s
```

The wizard will walk you through configuring your reverse proxy setup.

## 🎯 Understanding Proxy Types

nginx can route traffic in two fundamentally different ways:

### Port-Based Proxying

Each service gets its own port. Perfect for independent services:

```
Client              nginx                 Your Services
------              -----                 -------------
:8080  ───────────> :8080  ─────────────> localhost:3000 (frontend)
:8081  ───────────> :8081  ─────────────> localhost:5000 (backend)
:8082  ───────────> :8082  ─────────────> localhost:6379 (redis)
```

**Best for:**
- Separate, independent services
- Simple port mapping
- Services that don't need a unified entry point

**Example:**
- Access frontend: `http://localhost:8080`
- Access backend: `http://localhost:8081`
- Access Redis: `http://localhost:8082`

### Path-Based Proxying

All services share one port, accessed via different URL paths:

```
Client                 nginx (single port)           Your Services
------                 -------------------           -------------
/api/    ──┐
           ├─────────> :8080  ─────> /api/   ─────> localhost:5000 (backend)
/app/    ──┤                          /app/   ─────> localhost:3000 (frontend)
           └─────────>                /admin/ ─────> localhost:8080 (admin)
/admin/  ──┘
```

**Best for:**
- Microservices architecture
- Unified API gateway
- Single entry point for multiple services
- Frontend routing (e.g., `/api` for backend, `/` for SPA)

**Example:**
- Frontend: `http://localhost:8080/app/`
- Backend API: `http://localhost:8080/api/`
- Admin panel: `http://localhost:8080/admin/`

**Important:** Paths are stripped before forwarding!
- Request to `/api/users` forwards as `/users` to backend
- This is intentional reverse proxy behavior
- Configure your backend to expect paths without the prefix

### Both Types Together

You can configure both in a single setup:
- Port-based for some services (e.g., dedicated Redis dashboard)
- Path-based for others (e.g., unified web app)

## 🎨 Configuration Wizard

On first activation, the wizard asks:

1. **Proxy Type**: Port-based, Path-based, or Both
2. **For Port-Based**:
   - nginx listening port (e.g., 8080)
   - Target port to forward to (e.g., 3000)
   - Add more? (Yes/No)
3. **For Path-Based**:
   - Main listening port (e.g., 8080)
   - Path prefix (e.g., `/api`)
   - Target port for that path (e.g., 5000)
   - Add more paths? (Yes/No)
   - Default target for `/` (optional)
4. **IP Access Control**:
   - Restrict by IP? (Yes/No)
   - Allowed IPs/networks (e.g., `192.168.1.0/24`)

The wizard prevents common mistakes:
- Port conflicts are detected automatically
- Invalid IP addresses are rejected
- Clear examples shown for each input

## 📋 Configuration Examples

### Example 1: Simple Port Proxy

Proxy port 8080 to a local web app on port 3000:

**Wizard Inputs:**
- Proxy type: `Port-based Proxying`
- Listening port: `8080`
- Target port: `3000`
- Add another: `No`
- IP restriction: `No`

**Result:** `http://localhost:8080` → `http://localhost:3000`

### Example 2: Microservices with Path-Based Routing

Single entry point for multiple services:

**Wizard Inputs:**
- Proxy type: `Path-based Proxying`
- Main port: `8080`
- Path 1: `/api` → port `5000`
- Path 2: `/app` → port `3000`
- Path 3: `/admin` → port `8001`
- Default target: `3000` (frontend)
- IP restriction: `No`

**Result:**
- `http://localhost:8080/` → frontend (port 3000)
- `http://localhost:8080/api/` → backend API (port 5000)
- `http://localhost:8080/app/` → app (port 3000)
- `http://localhost:8080/admin/` → admin panel (port 8001)

### Example 3: Combined Setup with Access Control

Mix of port and path-based, restricted to local network:

**Wizard Inputs:**
- Proxy type: `Both`
- Port proxy 1: `8080` → `3000`
- Port proxy 2: `9000` → `6379` (Redis)
- Path-based port: `8081`
- Path 1: `/api` → `5000`
- Path 2: `/ws` → `3001` (WebSocket)
- Default target: `None` (info page)
- IP restriction: `Yes`
- Allowed IPs: `192.168.1.0/24 127.0.0.1`

**Result:**
- Port-based: `http://localhost:8080` and `http://localhost:9000`
- Path-based: `http://localhost:8081/api/` and `http://localhost:8081/ws/`
- Only accessible from `192.168.1.0/24` network and localhost

## 🔄 Reconfiguration

Need to change your setup?

### Force Reconfigure

```bash
FORCE_WIZARD=true flox activate -s
```

This wipes your configuration and re-runs the wizard.

### Quick Defaults (No Wizard)

For quick testing with defaults:

```bash
USE_DEFAULTS=true flox activate -s
```

**Defaults:**
- Port-based proxy: `8080` → `3000`
- No IP restrictions
- No path-based routing

## 🔧 WebSocket Support

WebSocket connections are automatically supported! nginx detects and upgrades WebSocket connections via the `Upgrade` header.

**Works with:**
- Socket.io applications
- WebSocket APIs
- Real-time chat apps
- Live dashboards
- Gaming servers

**Example WebSocket Path:**
- Configure path `/ws` → port `3001`
- Connect to: `ws://localhost:8080/ws/`

## 🔒 IP Access Control

Restrict access to specific IP addresses or networks:

**Single IP:**
```
192.168.1.100
```

**Network (CIDR):**
```
192.168.1.0/24
```

**Multiple entries (space-separated):**
```
192.168.1.0/24 10.0.0.0/8 127.0.0.1
```

**Validation:**
The wizard validates all IPs:
- Rejects invalid formats
- Checks octets are 0-255
- Validates CIDR prefixes (0-32)

## 📁 Configuration Persistence

Your configuration is saved in:
```
$FLOX_ENV_CACHE/proxy_config.env
```

This persists across activations. Delete this file to start fresh, or use `FORCE_WIZARD=true` to reconfigure.

## 🛠️ Under the Hood

### Generated nginx Configuration

nginx configuration is dynamically generated at:
```
$FLOX_ENV_CACHE/nginx/nginx.conf
```

View it:
```bash
cat .flox/cache/nginx/nginx.conf
```

### Log Files

Logs are stored in `$FLOX_ENV_CACHE/nginx/`:
- `error.log` - nginx errors and diagnostics
- `access.log` - HTTP request logs

View logs:
```bash
tail -f .flox/cache/nginx/error.log
tail -f .flox/cache/nginx/access.log
```

### How It Works

1. **Wizard Phase**: Interactive configuration wizard (unless `USE_DEFAULTS=true`)
2. **Generation Phase**: Creates nginx configuration from your choices
3. **Cleanup Phase**: Stops any existing nginx processes on configured ports
4. **Service Phase**: Starts nginx with generated configuration

## 🔥 Troubleshooting

### Service Won't Start

**Port Already in Use:**
```bash
# Check what's using the port
lsof -i :8080

# Kill the process or choose a different port
FORCE_WIZARD=true flox activate -s
```

**Configuration Error:**
```bash
# View nginx error log
cat .flox/cache/nginx/error.log

# Test configuration manually
nginx -t -c .flox/cache/nginx/nginx.conf
```

### Target Service Not Responding (502 Bad Gateway)

nginx is running but your backend service isn't:

1. **Check backend is running:**
   ```bash
   curl http://localhost:3000  # Replace with your port
   ```

2. **Check backend logs** for errors

3. **Verify port numbers** in wizard configuration

### Path-Based Routing Returns 404

**Problem:** Your backend doesn't handle the stripped paths.

**Example:**
- Request: `http://localhost:8080/api/users`
- nginx forwards: `http://localhost:5000/users` (stripped `/api`)
- Backend only routes `/api/users` → 404!

**Solutions:**
1. Configure backend to route `/users` instead of `/api/users`
2. Or use port-based proxying instead
3. Or configure backend to accept both routes

### IP Access Control Not Working

**Check configuration:**
```bash
cat .flox/cache/nginx/nginx.conf | grep -A 5 "access control"
```

**Verify your IP:**
```bash
curl ifconfig.me  # Your public IP
ip addr show      # Your local IPs
```

**Note:** `127.0.0.1` and `localhost` are different!
- Use `127.0.0.1` in allowed IPs for local access

### Complete Reset

```bash
# Stop nginx
flox services stop

# Delete all configuration and cache
rm -rf .flox/cache

# Reconfigure from scratch
flox activate -s
```

## 💻 System Support

Runs on:
- macOS (ARM/Intel)
- Linux (x86/ARM)

## 🎓 Common Patterns

### Pattern 1: Development API Gateway

Single entry point for frontend and backend:

```
Main port: 8080
Paths:
  /          → 3000 (React/Vue frontend)
  /api/      → 5000 (Node.js backend)
  /graphql/  → 4000 (GraphQL server)
```

Frontend makes requests to `/api/users` which routes to backend.

### Pattern 2: Service Dashboard Cluster

Multiple dashboards on separate ports:

```
Port-based:
  8080 → 3000 (Main app)
  8081 → 5601 (Kibana)
  8082 → 3001 (Grafana)
  8083 → 9000 (Portainer)
```

Each service accessible on its own port.

### Pattern 3: Hybrid Microservices

Mix of dedicated ports and path routing:

```
Port-based:
  9000 → 6379 (Redis admin UI)
  9001 → 5672 (RabbitMQ management)

Path-based (port 8080):
  /         → 3000 (Frontend)
  /api/     → 5000 (REST API)
  /graphql/ → 4000 (GraphQL)
  /ws/      → 3001 (WebSocket server)
```

### Pattern 4: Team Development Environment

Isolated services with access control:

```
Port-based:
  8080 → 3000 (Shared frontend)
  8081 → 5000 (Your backend)
  8082 → 5001 (Teammate's backend)

IP restriction: 192.168.1.0/24 (local network only)
```

## 🔍 nginx Interactive vs nginx-headless

This repository contains two nginx environments:

### nginx (This Environment)
- **Interactive wizard** for configuration
- **Port and path-based** proxying
- **WebSocket support**
- **IP access control**
- **Single mode:** Reverse proxy only
- **Best for:** Local development, learning, exploration

### nginx-headless
- **Environment variable** configuration
- **Three modes:** Reverse proxy, static server, load balancer
- **Advanced features:** SSL/TLS, rate limiting, gzip, caching, security headers
- **Zero interaction**
- **Best for:** Automation, CI/CD, production deployments

**When to Use Which:**
- **Use nginx (this)** for local dev, microservices routing, learning
- **Use nginx-headless** for production, containers, automated deployments

## 🔗 Related Environments

- [**nginx-headless**](../nginx-headless) - Production-ready nginx with SSL, rate limiting, and more
- [**postgres**](../postgres) - PostgreSQL database (pairs well with nginx)
- [**redis**](../redis) - Redis cache (common backend service)

## 📝 Recent Improvements

This environment recently received critical bug fixes:
- ✅ Fixed unsafe process termination (no longer kills non-nginx processes)
- ✅ Fixed proxy headers (correct `Host` header for backend routing)
- ✅ Enhanced IP validation (proper IPv4 and CIDR validation)
- ✅ Fixed regex escaping in path rewrites

All improvements verified and tested.

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix):

- **Declarative environments** - Software, variables, services defined in TOML
- **Content-addressed storage** - Multiple versions coexist without conflicts
- **Reproducibility** - Same environment across dev, CI, and production
- **Deterministic builds** - Same inputs always produce identical outputs
- **150,000+ packages** from [Nixpkgs](https://github.com/NixOS/nixpkgs)
